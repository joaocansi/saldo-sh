import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class PlatformSecretStore implements SecretStore {
  PlatformSecretStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class SecretKeys {
  const SecretKeys._();

  static const aiApiKey = 'verde.ai.api_key';
  static const driveCredentials = 'verde.drive.oauth_credentials';
  static const driveAndroidAuthorization = 'verde.drive.android_authorization';
  static const driveAndroidAccountEmail = 'verde.drive.android_account_email';
  static const syncEncryptionKey = 'verde.sync.encryption_key';
}
