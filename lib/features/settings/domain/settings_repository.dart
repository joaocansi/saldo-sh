import 'app_settings.dart';

abstract interface class SettingsRepository {
  Future<String?> readDisplayName();
  Future<void> saveDisplayName(String name);
  Future<AISettings> readAISettings();
  Future<void> saveAISettings(AISettings settings);
  Future<SyncSettings> readSyncSettings();
  Future<void> saveSyncSettings(SyncSettings settings);
}
