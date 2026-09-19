import 'package:saldo_sh/src/core/security/secret_store.dart';
import 'package:saldo_sh/src/features/sync/oauth/android_drive_token_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'restores a recent Android Drive token without user interaction',
    () async {
      final secrets = _MemorySecretStore();
      var now = DateTime.utc(2026, 9, 15, 12);
      final store = AndroidDriveTokenStore(secrets, clock: () => now);

      await store.save(
        accessToken: 'protected-access-token',
        accountEmail: 'user@example.com',
      );
      now = now.add(const Duration(minutes: 30));

      final restored = await store.readValid();
      expect(restored?.accessToken, 'protected-access-token');
      expect(restored?.accountEmail, 'user@example.com');
    },
  );

  test('expires and removes an old Android Drive token', () async {
    final secrets = _MemorySecretStore();
    var now = DateTime.utc(2026, 9, 15, 12);
    final store = AndroidDriveTokenStore(secrets, clock: () => now);
    await store.save(
      accessToken: 'expired-token',
      accountEmail: 'user@example.com',
    );

    now = now.add(const Duration(minutes: 50));

    expect(await store.readValid(), isNull);
    expect(await secrets.read(SecretKeys.driveAndroidAuthorization), isNull);
    expect(await store.readAccountEmail(), 'user@example.com');
  });

  test('rejects malformed cached credentials', () async {
    final secrets = _MemorySecretStore();
    await secrets.write(SecretKeys.driveAndroidAuthorization, '{invalid');
    final store = AndroidDriveTokenStore(secrets);

    expect(await store.readValid(), isNull);
    expect(await secrets.read(SecretKeys.driveAndroidAuthorization), isNull);
  });

  test('disconnect cleanup removes token and remembered account', () async {
    final secrets = _MemorySecretStore();
    final store = AndroidDriveTokenStore(secrets);
    await store.save(
      accessToken: 'access-token',
      accountEmail: 'user@example.com',
    );

    expect(await store.readAccessToken(), 'access-token');
    await store.clear();

    expect(await store.readValid(), isNull);
    expect(await store.readAccessToken(), isNull);
    expect(await store.readAccountEmail(), isNull);
  });
}

class _MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
