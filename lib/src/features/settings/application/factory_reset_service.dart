import '../../../core/database/app_database.dart';
import '../../../core/security/secret_store.dart';
import '../../sync/application/drive_sync_controller.dart';

class FactoryResetService {
  FactoryResetService(this._database, this._secretStore);

  final AppDatabase _database;
  final SecretStore _secretStore;

  Future<void> execute(DriveSyncController sync) async {
    await sync.prepareFactoryReset();
    await sync.releaseAfterFactoryReset();
    await Future.wait([
      _secretStore.delete(SecretKeys.aiApiKey),
      _secretStore.delete(SecretKeys.driveCredentials),
      _secretStore.delete(SecretKeys.driveAndroidAuthorization),
      _secretStore.delete(SecretKeys.driveAndroidAccountEmail),
      _secretStore.delete(SecretKeys.syncEncryptionKey),
    ]);
    await _database.clearAllUserData();
  }
}
