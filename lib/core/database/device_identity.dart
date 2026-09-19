import 'package:uuid/uuid.dart';

import 'app_database.dart';

class DeviceIdentity {
  DeviceIdentity(this._database, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const _deviceIdKey = 'device_id';
  static const _counterKey = 'device_counter';

  final AppDatabase _database;
  final Uuid _uuid;

  Future<String> getOrCreateId() async {
    final existing = await (_database.select(
      _database.syncMetadata,
    )..where((row) => row.key.equals(_deviceIdKey))).getSingleOrNull();
    if (existing != null && existing.value.isNotEmpty) return existing.value;

    final id = _uuid.v4();
    await _database
        .into(_database.syncMetadata)
        .insertOnConflictUpdate(
          SyncMetadataCompanion.insert(key: _deviceIdKey, value: id),
        );
    return id;
  }

  Future<int> nextCounter() => _database.transaction(() async {
    final existing = await (_database.select(
      _database.syncMetadata,
    )..where((row) => row.key.equals(_counterKey))).getSingleOrNull();
    final next = (int.tryParse(existing?.value ?? '') ?? 0) + 1;
    await _database
        .into(_database.syncMetadata)
        .insertOnConflictUpdate(
          SyncMetadataCompanion.insert(key: _counterKey, value: '$next'),
        );
    return next;
  });
}
