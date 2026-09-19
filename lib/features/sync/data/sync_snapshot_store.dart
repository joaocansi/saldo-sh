import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/device_identity.dart';
import '../../../core/sync/vector_clock.dart';
import '../domain/sync_models.dart';

class SyncSnapshotStore {
  SyncSnapshotStore(this._database, this._deviceIdentity, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final DeviceIdentity _deviceIdentity;
  final Uuid _uuid;

  static const resetMarkerKey = 'sync.reset_id';

  Future<Map<String, dynamic>> exportSnapshot() async {
    final resetId = await _readMetadata(resetMarkerKey);
    final accounts = await _database.select(_database.accountRecords).get();
    final transactions = await _database
        .select(_database.transactionRecords)
        .get();
    final budgets = await _database.select(_database.budgetRecords).get();
    final recurrences = await _database
        .select(_database.recurrenceRecords)
        .get();
    final preferences = await (_database.select(
      _database.preferenceRecords,
    )..where((row) => row.synchronizable.equals(true))).get();
    final tombstones = await _database.select(_database.tombstoneRecords).get();
    return {
      'schemaVersion': 3,
      'resetId': ?resetId,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'accounts': accounts.map((row) => row.toJson()).toList(),
      'transactions': transactions.map((row) => row.toJson()).toList(),
      'budgets': budgets.map((row) => row.toJson()).toList(),
      'recurrences': recurrences.map((row) => row.toJson()).toList(),
      'preferences': preferences.map((row) => row.toJson()).toList(),
      'tombstones': tombstones.map((row) => row.toJson()).toList(),
    };
  }

  Future<SyncMergeResult> merge(Map<String, dynamic> remote) async {
    final schemaVersion = remote['schemaVersion'];
    if (schemaVersion != 1 && schemaVersion != 2 && schemaVersion != 3) {
      throw const FormatException('Versão do snapshot não suportada.');
    }
    final remoteResetId = remote['resetId'] as String?;
    if (schemaVersion == 2 &&
        (remoteResetId == null || remoteResetId.trim().isEmpty)) {
      throw const FormatException('Snapshot de reset sem identificador.');
    }
    var changed = false;
    var conflicts = 0;
    await _database.transaction(() async {
      final localResetId = await _readMetadata(resetMarkerKey);
      if ((schemaVersion == 1 ||
              (schemaVersion == 3 && remoteResetId == null)) &&
          localResetId != null) {
        return;
      }
      if ((schemaVersion == 2 || schemaVersion == 3) &&
          remoteResetId != null &&
          remoteResetId != localResetId) {
        await _applyRemoteReset(remoteResetId);
        changed = true;
      }
      final results = <SyncMergeResult>[];
      results.add(
        await _mergeCollection(
          'account',
          await _database.select(_database.accountRecords).get(),
          _list(remote, 'accounts'),
          (row) => row.id,
          (row) => row.vectorClock,
          (row) => row.toJson(),
        ),
      );
      results.add(
        await _mergeCollection(
          'transaction',
          await _database.select(_database.transactionRecords).get(),
          _list(remote, 'transactions'),
          (row) => row.id,
          (row) => row.vectorClock,
          (row) => row.toJson(),
        ),
      );
      results.add(
        await _mergeCollection(
          'budget',
          await _database.select(_database.budgetRecords).get(),
          _list(remote, 'budgets'),
          (row) => row.id,
          (row) => row.vectorClock,
          (row) => row.toJson(),
        ),
      );
      results.add(
        await _mergeCollection(
          'recurrence',
          await _database.select(_database.recurrenceRecords).get(),
          _list(remote, 'recurrences'),
          (row) => row.id,
          (row) => row.vectorClock,
          (row) => row.toJson(),
        ),
      );
      results.add(
        await _mergeCollection(
          'preference',
          await (_database.select(
            _database.preferenceRecords,
          )..where((row) => row.synchronizable.equals(true))).get(),
          _list(remote, 'preferences'),
          (row) => row.key,
          (row) => row.vectorClock,
          (row) => row.toJson(),
        ),
      );
      for (final result in results) {
        changed = changed || result.changed;
        conflicts += result.conflicts;
      }
      final tombstoneResult = await _mergeTombstones(
        _list(remote, 'tombstones'),
      );
      changed = tombstoneResult.changed || changed;
      conflicts += tombstoneResult.conflicts;
    });
    return SyncMergeResult(changed: changed, conflicts: conflicts);
  }

  Map<String, dynamic> emptyResetSnapshot(String resetId) => {
    'schemaVersion': 3,
    'resetId': resetId,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'accounts': const <Object>[],
    'transactions': const <Object>[],
    'budgets': const <Object>[],
    'recurrences': const <Object>[],
    'preferences': const <Object>[],
    'tombstones': const <Object>[],
  };

  Future<void> _applyRemoteReset(String resetId) async {
    await _database.delete(_database.aIToolAuditRecords).go();
    await _database.delete(_database.syncConflictRecords).go();
    await _database.delete(_database.tombstoneRecords).go();
    await _database.delete(_database.recurrenceRecords).go();
    await _database.delete(_database.transactionRecords).go();
    await _database.delete(_database.budgetRecords).go();
    await _database.delete(_database.accountRecords).go();
    await (_database.delete(
      _database.preferenceRecords,
    )..where((row) => row.synchronizable.equals(true))).go();
    await _database
        .into(_database.syncMetadata)
        .insertOnConflictUpdate(
          SyncMetadataCompanion.insert(key: resetMarkerKey, value: resetId),
        );
  }

  Future<String?> _readMetadata(String key) async => (await (_database.select(
    _database.syncMetadata,
  )..where((row) => row.key.equals(key))).getSingleOrNull())?.value;

  Future<SyncMergeResult> _mergeCollection<T>(
    String type,
    List<T> localRows,
    List<Map<String, dynamic>> remoteRows,
    String Function(T) idOf,
    String Function(T) clockOf,
    Map<String, dynamic> Function(T) jsonOf,
  ) async {
    final locals = {for (final row in localRows) idOf(row): row};
    var changed = false;
    var conflicts = 0;
    for (final remote in remoteRows) {
      final id = (remote[type == 'preference' ? 'key' : 'id'] as String?) ?? '';
      if (id.isEmpty) throw const FormatException('Registro remoto sem ID.');
      final local = locals[id];
      if (local == null) {
        await _upsert(type, remote);
        changed = true;
        continue;
      }
      final localJson = jsonOf(local);
      final relation = VectorClock.fromJsonString(clockOf(local)).compare(
        VectorClock.fromJsonString(remote['vectorClock'] as String? ?? '{}'),
      );
      if (relation == ClockRelation.remoteDominates) {
        await _upsert(type, remote);
        changed = true;
      } else if (relation == ClockRelation.concurrent) {
        if (_contentJson(localJson) == _contentJson(remote)) {
          final merged = VectorClock.fromJsonString(clockOf(local))
              .merged(
                VectorClock.fromJsonString(
                  remote['vectorClock'] as String? ?? '{}',
                ),
              )
              .toJsonString();
          await _upsert(type, {...localJson, 'vectorClock': merged});
          changed = true;
        } else if (!await _conflictExists(type, id)) {
          await _database
              .into(_database.syncConflictRecords)
              .insert(
                SyncConflictRecordsCompanion.insert(
                  id: _uuid.v4(),
                  entityType: type,
                  entityId: id,
                  localJson: jsonEncode(localJson),
                  remoteJson: jsonEncode(remote),
                  createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
                ),
              );
          conflicts++;
        }
      }
    }
    return SyncMergeResult(changed: changed, conflicts: conflicts);
  }

  Future<SyncMergeResult> _mergeTombstones(
    List<Map<String, dynamic>> remoteRows,
  ) async {
    var changed = false;
    var conflicts = 0;
    final localRows = await _database.select(_database.tombstoneRecords).get();
    final locals = {
      for (final row in localRows) '${row.entityType}:${row.entityId}': row,
    };
    for (final remote in remoteRows) {
      final row = TombstoneRecord.fromJson(remote);
      if (!{
        'account',
        'transaction',
        'budget',
        'recurrence',
      }.contains(row.entityType)) {
        throw const FormatException('Tombstone remoto inválido.');
      }
      final key = '${row.entityType}:${row.entityId}';
      final local = locals[key];
      final localEntity = await _findEntity(row.entityType, row.entityId);
      final localClock =
          localEntity?['vectorClock'] as String? ?? local?.vectorClock ?? '{}';
      final relation = VectorClock.fromJsonString(localClock)
          .compare(VectorClock.fromJsonString(row.vectorClock));
      final recordAlreadyDeleted =
          local == null && localEntity?['deletedAt'] != null;
      if (relation == ClockRelation.remoteDominates || recordAlreadyDeleted) {
        await _database
            .into(_database.tombstoneRecords)
            .insertOnConflictUpdate(row);
        await _applyTombstone(row);
        changed = true;
      } else if (relation == ClockRelation.concurrent &&
          localEntity != null &&
          localEntity['deletedAt'] == null &&
          !await _conflictExists(row.entityType, row.entityId)) {
        await _database
            .into(_database.syncConflictRecords)
            .insert(
              SyncConflictRecordsCompanion.insert(
                id: _uuid.v4(),
                entityType: row.entityType,
                entityId: row.entityId,
                localJson: jsonEncode(localEntity),
                remoteJson: jsonEncode({'_tombstone': remote}),
                createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
              ),
            );
        conflicts++;
      }
    }
    return SyncMergeResult(changed: changed, conflicts: conflicts);
  }

  Future<void> _applyTombstone(TombstoneRecord tombstone) async {
    final deleted = Value<int?>(tombstone.deletedAt);
    switch (tombstone.entityType) {
      case 'account':
        await (_database.update(
          _database.accountRecords,
        )..where((row) => row.id.equals(tombstone.entityId))).write(
          AccountRecordsCompanion(
            deletedAt: deleted,
            updatedAt: Value(tombstone.deletedAt),
            originDeviceId: Value(tombstone.originDeviceId),
            vectorClock: Value(tombstone.vectorClock),
          ),
        );
      case 'transaction':
        await (_database.update(
          _database.transactionRecords,
        )..where((row) => row.id.equals(tombstone.entityId))).write(
          TransactionRecordsCompanion(
            deletedAt: deleted,
            updatedAt: Value(tombstone.deletedAt),
            originDeviceId: Value(tombstone.originDeviceId),
            vectorClock: Value(tombstone.vectorClock),
          ),
        );
      case 'budget':
        await (_database.update(
          _database.budgetRecords,
        )..where((row) => row.id.equals(tombstone.entityId))).write(
          BudgetRecordsCompanion(
            deletedAt: deleted,
            updatedAt: Value(tombstone.deletedAt),
            originDeviceId: Value(tombstone.originDeviceId),
            vectorClock: Value(tombstone.vectorClock),
          ),
        );
      case 'recurrence':
        await (_database.update(
          _database.recurrenceRecords,
        )..where((row) => row.id.equals(tombstone.entityId))).write(
          RecurrenceRecordsCompanion(
            deletedAt: deleted,
            updatedAt: Value(tombstone.deletedAt),
            originDeviceId: Value(tombstone.originDeviceId),
            vectorClock: Value(tombstone.vectorClock),
          ),
        );
    }
  }

  Future<void> _upsert(String type, Map<String, dynamic> json) async {
    switch (type) {
      case 'account':
        await _database
            .into(_database.accountRecords)
            .insertOnConflictUpdate(AccountRecord.fromJson(json));
      case 'transaction':
        await _database
            .into(_database.transactionRecords)
            .insertOnConflictUpdate(TransactionRecord.fromJson(json));
      case 'budget':
        await _database
            .into(_database.budgetRecords)
            .insertOnConflictUpdate(BudgetRecord.fromJson(json));
      case 'recurrence':
        await _database
            .into(_database.recurrenceRecords)
            .insertOnConflictUpdate(RecurrenceRecord.fromJson(json));
      case 'preference':
        final record = PreferenceRecord.fromJson(json);
        if (record.synchronizable) {
          await _database
              .into(_database.preferenceRecords)
              .insertOnConflictUpdate(record);
        }
      default:
        if (!{
          'account',
          'transaction',
          'budget',
          'recurrence',
          'preference',
        }.contains(type)) {
          throw const FormatException('Tipo de registro remoto inválido.');
        }
    }
  }

  Future<bool> _conflictExists(String type, String id) async =>
      await (_database.select(_database.syncConflictRecords)..where(
            (row) => row.entityType.equals(type) & row.entityId.equals(id),
          ))
          .getSingleOrNull() !=
      null;

  Future<List<SyncConflictRecord>> readConflicts() => (_database.select(
    _database.syncConflictRecords,
  )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).get();

  Future<void> resolveConflict(
    SyncConflictRecord conflict, {
    required bool useRemote,
  }) async {
    final local = Map<String, dynamic>.from(
      jsonDecode(conflict.localJson) as Map,
    );
    final remote = Map<String, dynamic>.from(
      jsonDecode(conflict.remoteJson) as Map,
    );
    final tombstoneJson = remote['_tombstone'];
    if (useRemote && tombstoneJson is Map) {
      final tombstone = TombstoneRecord.fromJson(
        Map<String, dynamic>.from(tombstoneJson),
      );
      await _database
          .into(_database.tombstoneRecords)
          .insertOnConflictUpdate(tombstone);
      await _applyTombstone(tombstone);
    } else if (useRemote) {
      await _upsert(conflict.entityType, remote);
      await _ensureTombstoneForDeletedRecord(conflict.entityType, remote);
    } else {
      final deviceId = await _deviceIdentity.getOrCreateId();
      final counter = await _deviceIdentity.nextCounter();
      final merged = VectorClock.fromJsonString(
        local['vectorClock'] as String? ?? '{}',
      ).merged(VectorClock.fromJsonString(_remoteClock(remote)));
      final values = Map<String, int>.from(merged.values)..[deviceId] = counter;
      await _upsert(conflict.entityType, {
        ...local,
        'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
        'originDeviceId': deviceId,
        'vectorClock': VectorClock(values).toJsonString(),
      });
    }
    await (_database.delete(
      _database.syncConflictRecords,
    )..where((row) => row.id.equals(conflict.id))).go();
  }

  String _remoteClock(Map<String, dynamic> remote) {
    final tombstone = remote['_tombstone'];
    if (tombstone is Map) {
      return tombstone['vectorClock'] as String? ?? '{}';
    }
    return remote['vectorClock'] as String? ?? '{}';
  }

  Future<void> _ensureTombstoneForDeletedRecord(
    String type,
    Map<String, dynamic> record,
  ) async {
    final deletedAt = record['deletedAt'];
    final id = record['id'];
    if (deletedAt is! int || id is! String || type == 'preference') return;
    await _database
        .into(_database.tombstoneRecords)
        .insertOnConflictUpdate(
          TombstoneRecord(
            entityType: type,
            entityId: id,
            deletedAt: deletedAt,
            originDeviceId: record['originDeviceId'] as String? ?? '',
            vectorClock: record['vectorClock'] as String? ?? '{}',
          ),
        );
  }

  Future<Map<String, dynamic>?> _findEntity(String type, String id) async {
    switch (type) {
      case 'account':
        return (await (_database.select(
          _database.accountRecords,
        )..where((row) => row.id.equals(id))).getSingleOrNull())?.toJson();
      case 'transaction':
        return (await (_database.select(
          _database.transactionRecords,
        )..where((row) => row.id.equals(id))).getSingleOrNull())?.toJson();
      case 'budget':
        return (await (_database.select(
          _database.budgetRecords,
        )..where((row) => row.id.equals(id))).getSingleOrNull())?.toJson();
      case 'recurrence':
        return (await (_database.select(
          _database.recurrenceRecords,
        )..where((row) => row.id.equals(id))).getSingleOrNull())?.toJson();
      default:
        return null;
    }
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return [];
    if (value is! List) throw FormatException('$key inválido no snapshot.');
    return value.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  String _contentJson(Map<String, dynamic> json) {
    final content = Map<String, dynamic>.from(json)
      ..remove('updatedAt')
      ..remove('originDeviceId')
      ..remove('vectorClock');
    return jsonEncode(content);
  }
}
