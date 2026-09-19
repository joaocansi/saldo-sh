import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:saldo_sh/src/core/database/app_database.dart';
import 'package:saldo_sh/src/core/database/device_identity.dart';
import 'package:saldo_sh/src/core/security/secret_store.dart';
import 'package:saldo_sh/src/features/finance/data/local/drift_finance_repository.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:saldo_sh/src/features/settings/application/factory_reset_service.dart';
import 'package:saldo_sh/src/features/settings/data/drift_settings_repository.dart';
import 'package:saldo_sh/src/features/settings/domain/app_settings.dart';
import 'package:saldo_sh/src/features/sync/application/drive_sync_controller.dart';
import 'package:saldo_sh/src/features/sync/application/sync_engine.dart';
import 'package:saldo_sh/src/features/sync/data/google_drive_remote_store.dart';
import 'package:saldo_sh/src/features/sync/data/sync_snapshot_store.dart';
import 'package:saldo_sh/src/features/sync/domain/sync_models.dart';
import 'package:saldo_sh/src/features/sync/oauth/drive_auth_service.dart';
import 'package:saldo_sh/src/features/sync/security/sync_cipher.dart';
import 'package:saldo_sh/src/features/sync/security/sync_key_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  late AppDatabase database;
  late DeviceIdentity identity;
  late DriftFinanceRepository finance;
  late DriftSettingsRepository settings;
  late _MemorySecretStore secrets;
  late SyncCipher cipher;
  late SyncKeyManager keyManager;
  late SyncSnapshotStore snapshots;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    identity = DeviceIdentity(database);
    finance = DriftFinanceRepository(database, identity);
    settings = DriftSettingsRepository(database, identity);
    secrets = _MemorySecretStore();
    cipher = SyncCipher(memory: 8192, iterations: 1);
    keyManager = SyncKeyManager(secrets, cipher);
    snapshots = SyncSnapshotStore(database, identity);
  });

  tearDown(() => database.close());

  test('local factory reset clears database and secrets', () async {
    await _seed(finance, settings, secrets);
    final sync = _controller(
      settings: settings,
      secrets: secrets,
      keyManager: keyManager,
      cipher: cipher,
      snapshots: snapshots,
      remote: _MemoryRemoteStore(),
    );
    addTearDown(sync.dispose);

    await FactoryResetService(database, secrets).execute(sync);

    expect(await finance.readAccounts(), isEmpty);
    expect(await settings.readDisplayName(), isNull);
    expect(await database.select(database.preferenceRecords).get(), isEmpty);
    expect(secrets.values, isEmpty);
  });

  test('remote failure preserves all local data and secrets', () async {
    await _seed(finance, settings, secrets);
    await settings.saveSyncSettings(
      const SyncSettings(enabled: true, accountEmail: 'user@example.com'),
    );
    await keyManager.create('senha-de-sync-segura');
    final sync = _controller(
      settings: settings,
      secrets: secrets,
      keyManager: keyManager,
      cipher: cipher,
      snapshots: snapshots,
      remote: _FailingRemoteStore(),
    );
    addTearDown(sync.dispose);
    await sync.initialize();

    await expectLater(
      FactoryResetService(database, secrets).execute(sync),
      throwsA(isA<DriveRemoteException>()),
    );

    expect((await finance.readAccounts()).single.name, 'Conta');
    expect(await settings.readDisplayName(), 'João');
    expect(await secrets.read(SecretKeys.aiApiKey), 'secret-ai-key');
    expect(
      await secrets.read(SecretKeys.driveAndroidAuthorization),
      'cached-drive-token',
    );
    expect(
      await secrets.read(SecretKeys.driveAndroidAccountEmail),
      'user@example.com',
    );
    expect(await secrets.read(SecretKeys.syncEncryptionKey), isNotNull);
  });
}

Future<void> _seed(
  DriftFinanceRepository finance,
  DriftSettingsRepository settings,
  _MemorySecretStore secrets,
) async {
  await finance.saveAccounts([
    FinanceAccount(
      id: 'account-1',
      name: 'Conta',
      kind: 'account',
      openingBalance: 100,
    ),
  ]);
  await settings.saveDisplayName('João');
  await secrets.write(SecretKeys.aiApiKey, 'secret-ai-key');
  await secrets.write(
    SecretKeys.driveAndroidAuthorization,
    'cached-drive-token',
  );
  await secrets.write(SecretKeys.driveAndroidAccountEmail, 'user@example.com');
}

DriveSyncController _controller({
  required DriftSettingsRepository settings,
  required _MemorySecretStore secrets,
  required SyncKeyManager keyManager,
  required SyncCipher cipher,
  required SyncSnapshotStore snapshots,
  required DriveRemoteStore remote,
}) => DriveSyncController(
  _FakeAuthService(),
  settings,
  keyManager,
  SyncEngine(snapshots, cipher),
  snapshots,
  onRemoteDataChanged: () async {},
  remoteStoreFactory: (_) => remote,
);

class _FakeAuthService implements DriveAuthService {
  @override
  Future<DriveAuthSession> connect() async => _session();

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> invalidateCachedSession() async {}

  @override
  Future<DriveAuthSession?> restore() async => _session();

  DriveAuthSession _session() =>
      DriveAuthSession(client: http.Client(), accountEmail: 'user@example.com');
}

class _MemorySecretStore implements SecretStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

class _MemoryRemoteStore implements DriveRemoteStore {
  RemoteSnapshot? snapshot;

  @override
  Future<RemoteSnapshot?> download() async => snapshot;

  @override
  Future<void> upload(Uint8List bytes, {RemoteSnapshot? previous}) async {
    snapshot = RemoteSnapshot(
      fileId: previous?.fileId ?? 'file-1',
      bytes: bytes,
      version: '${int.parse(previous?.version ?? '0') + 1}',
    );
  }
}

class _FailingRemoteStore implements DriveRemoteStore {
  @override
  Future<RemoteSnapshot?> download() =>
      throw const DriveRemoteException('Sem conexão com o Google Drive.');

  @override
  Future<void> upload(Uint8List bytes, {RemoteSnapshot? previous}) async {}
}
