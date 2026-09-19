import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:saldo_sh/src/core/database/app_database.dart';
import 'package:saldo_sh/src/core/database/device_identity.dart';
import 'package:saldo_sh/src/core/security/secret_store.dart';
import 'package:saldo_sh/src/features/settings/domain/app_settings.dart';
import 'package:saldo_sh/src/features/settings/domain/settings_repository.dart';
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
  late _MemorySecretStore secrets;
  late _FakeAuthService auth;
  late _FakeDriveStore remote;
  late DriveSyncController controller;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    secrets = _MemorySecretStore();
    auth = _FakeAuthService();
    final cipher = SyncCipher(memory: 8192, iterations: 1);
    final keyManager = SyncKeyManager(secrets, cipher);
    await keyManager.create('senha-de-sync-segura');
    final localStore = SyncSnapshotStore(database, DeviceIdentity(database));
    remote = _FakeDriveStore();
    controller = DriveSyncController(
      auth,
      _MemorySettingsRepository(),
      keyManager,
      SyncEngine(localStore, cipher),
      localStore,
      onRemoteDataChanged: () async {},
      remoteStoreFactory: (_) => remote,
    );
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test('reuses the restored session in later synchronizations', () async {
    await controller.initialize();

    expect(auth.restoreCalls, 1);
    expect(controller.status, SyncStatus.synced);

    await controller.syncNow();

    expect(auth.restoreCalls, 1);
    expect(controller.status, SyncStatus.synced);

    controller.status = SyncStatus.conflict;
    await controller.onResumed();

    expect(auth.restoreCalls, 1);
    expect(controller.status, SyncStatus.conflict);
  });

  test('reconnects only after an explicit action', () async {
    auth.restoreAvailable = false;

    await controller.initialize();

    expect(controller.status, SyncStatus.disconnected);
    expect(controller.needsGoogleReconnect, isTrue);
    expect(auth.connectCalls, 0);

    await controller.reconnect();

    expect(auth.connectCalls, 1);
    expect(controller.needsGoogleReconnect, isFalse);
    expect(controller.status, SyncStatus.synced);
  });

  test(
    'a 401 invalidates the cache without opening login automatically',
    () async {
      await controller.initialize();
      remote.unauthorized = true;

      await controller.syncNow();

      expect(auth.invalidationCalls, 2);
      expect(auth.restoreCalls, 2);
      expect(auth.connectCalls, 0);
      expect(controller.needsGoogleReconnect, isTrue);
      expect(controller.status, SyncStatus.error);
      expect(controller.errorMessage, contains('Reconectar Google'));
    },
  );
}

class _FakeAuthService implements DriveAuthService {
  int restoreCalls = 0;
  int invalidationCalls = 0;
  int connectCalls = 0;
  bool restoreAvailable = true;

  @override
  Future<DriveAuthSession> connect() async {
    connectCalls++;
    return _session();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> invalidateCachedSession() async => invalidationCalls++;

  @override
  Future<DriveAuthSession?> restore() async {
    restoreCalls++;
    return restoreAvailable ? _session() : null;
  }

  DriveAuthSession _session() =>
      DriveAuthSession(client: http.Client(), accountEmail: 'user@example.com');
}

class _MemorySettingsRepository implements SettingsRepository {
  SyncSettings sync = const SyncSettings(
    enabled: true,
    accountEmail: 'user@example.com',
  );
  AISettings ai = const AISettings();

  @override
  Future<String?> readDisplayName() async => null;

  @override
  Future<AISettings> readAISettings() async => ai;

  @override
  Future<SyncSettings> readSyncSettings() async => sync;

  @override
  Future<void> saveAISettings(AISettings settings) async => ai = settings;

  @override
  Future<void> saveDisplayName(String name) async {}

  @override
  Future<void> saveSyncSettings(SyncSettings settings) async => sync = settings;
}

class _MemorySecretStore implements SecretStore {
  final Map<String, String> _values = {};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

class _FakeDriveStore implements DriveRemoteStore {
  RemoteSnapshot? snapshot;
  int version = 0;
  bool unauthorized = false;

  @override
  Future<RemoteSnapshot?> download() async {
    if (unauthorized) {
      throw const DriveRemoteException('Não autorizado.', status: 401);
    }
    return snapshot;
  }

  @override
  Future<void> upload(Uint8List bytes, {RemoteSnapshot? previous}) async {
    version++;
    snapshot = RemoteSnapshot(
      fileId: previous?.fileId ?? 'file-1',
      bytes: bytes,
      version: '$version',
    );
  }
}
