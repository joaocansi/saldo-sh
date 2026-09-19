import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/device_identity.dart';
import '../../../core/sync/vector_clock.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._database, this._deviceIdentity);

  static const aiKey = 'settings.ai';
  static const syncKey = 'settings.sync';
  static const displayNameKey = 'profile.displayName';

  final AppDatabase _database;
  final DeviceIdentity _deviceIdentity;

  @override
  Future<String?> readDisplayName() async {
    final json = await _readJson(displayNameKey);
    final value = json?['value'] as String?;
    return value == null || value.trim().isEmpty ? null : value.trim();
  }

  @override
  Future<void> saveDisplayName(String name) =>
      _writeJson(displayNameKey, {'value': name}, synchronizable: false);

  @override
  Future<AISettings> readAISettings() async =>
      AISettings.fromJson(await _readJson(aiKey));

  @override
  Future<void> saveAISettings(AISettings settings) =>
      _writeJson(aiKey, settings.toJson());

  @override
  Future<SyncSettings> readSyncSettings() async =>
      SyncSettings.fromJson(await _readJson(syncKey));

  @override
  Future<void> saveSyncSettings(SyncSettings settings) =>
      _writeJson(syncKey, settings.toJson());

  Future<Map<String, dynamic>?> _readJson(String key) async {
    final row = await (_database.select(
      _database.preferenceRecords,
    )..where((item) => item.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    return Map<String, dynamic>.from(jsonDecode(row.valueJson) as Map);
  }

  Future<void> _writeJson(
    String key,
    Map<String, dynamic> json, {
    bool? synchronizable,
  }) async {
    final encoded = jsonEncode(json);
    final current = await (_database.select(
      _database.preferenceRecords,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    if (current?.valueJson == encoded) return;

    final deviceId = await _deviceIdentity.getOrCreateId();
    final counter = await _deviceIdentity.nextCounter();
    final clock = VectorClock.fromJsonString(current?.vectorClock ?? '{}');
    final values = Map<String, int>.from(clock.values)..[deviceId] = counter;
    await _database
        .into(_database.preferenceRecords)
        .insertOnConflictUpdate(
          PreferenceRecordsCompanion.insert(
            key: key,
            valueJson: encoded,
            synchronizable: Value(synchronizable ?? key != syncKey),
            updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
            originDeviceId: deviceId,
            vectorClock: Value(VectorClock(values).toJsonString()),
          ),
        );
  }
}
