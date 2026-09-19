import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_application_1/core/database/app_database.dart';
import 'package:flutter_application_1/core/database/device_identity.dart';
import 'package:flutter_application_1/features/finance/data/local/drift_finance_repository.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_application_1/features/sync/application/sync_engine.dart';
import 'package:flutter_application_1/features/sync/data/sync_snapshot_store.dart';
import 'package:flutter_application_1/features/sync/domain/sync_models.dart';
import 'package:flutter_application_1/features/sync/security/sync_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncSnapshotStore localStore;
  late SyncCipher cipher;
  late SyncEngine engine;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final identity = DeviceIdentity(database);
    localStore = SyncSnapshotStore(database, identity);
    cipher = SyncCipher(memory: 8192, iterations: 1);
    engine = SyncEngine(localStore, cipher);
  });

  tearDown(() => database.close());

  test('uploads through a fake Drive transport and retries one 412', () async {
    final identity = DeviceIdentity(database);
    final repository = DriftFinanceRepository(database, identity);
    await repository.saveAccounts([
      FinanceAccount(
        id: 'account-1',
        name: 'Conta',
        kind: 'account',
        openingBalance: 20,
      ),
    ]);
    final key = await cipher.deriveNew('senha-de-sync-segura');
    final remote = _FakeDriveStore();

    await engine.synchronize(remoteStore: remote, key: key);
    expect(remote.uploadCalls, 1);
    expect(remote.snapshot, isNotNull);

    remote.failNextUpload = true;
    await engine.synchronize(remoteStore: remote, key: key);
    expect(remote.uploadCalls, 3);
  });

  test('wrong key never overwrites the remote snapshot', () async {
    final correct = await cipher.deriveNew('senha-correta-segura');
    final wrong = await cipher.deriveNew('senha-incorreta-segura');
    final bytes = await cipher.encrypt(
      Uint8List.fromList(utf8.encode(jsonEncode({'schemaVersion': 1}))),
      correct,
    );
    final remote = _FakeDriveStore()
      ..snapshot = RemoteSnapshot(fileId: 'file-1', bytes: bytes, version: '1');

    await expectLater(
      engine.synchronize(remoteStore: remote, key: wrong),
      throwsA(anything),
    );
    expect(remote.uploadCalls, 0);
  });

  test('replaces the remote snapshot with an encrypted reset marker', () async {
    final key = await cipher.deriveNew('senha-de-sync-segura');
    final remote = _FakeDriveStore();
    await engine.synchronize(remoteStore: remote, key: key);

    remote.failNextUpload = true;
    final resetId = await engine.resetRemote(remoteStore: remote, key: key);

    final clear = await cipher.decrypt(remote.snapshot!.bytes, key);
    final snapshot = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(clear)) as Map,
    );
    expect(snapshot['schemaVersion'], 3);
    expect(snapshot['resetId'], resetId);
    expect(snapshot['accounts'], isEmpty);
    expect(remote.uploadCalls, 3);
  });

  test('wrong key never overwrites the remote during reset', () async {
    final correct = await cipher.deriveNew('senha-correta-segura');
    final wrong = await cipher.deriveNew('senha-incorreta-segura');
    final bytes = await cipher.encrypt(
      Uint8List.fromList(
        utf8.encode(jsonEncode({'schemaVersion': 1, 'accounts': []})),
      ),
      correct,
    );
    final remote = _FakeDriveStore()
      ..snapshot = RemoteSnapshot(fileId: 'file-1', bytes: bytes, version: '1');

    await expectLater(
      engine.resetRemote(remoteStore: remote, key: wrong),
      throwsA(anything),
    );

    expect(remote.uploadCalls, 0);
  });
}

class _FakeDriveStore implements DriveRemoteStore {
  RemoteSnapshot? snapshot;
  int uploadCalls = 0;
  bool failNextUpload = false;

  @override
  Future<RemoteSnapshot?> download() async => snapshot;

  @override
  Future<void> upload(Uint8List bytes, {RemoteSnapshot? previous}) async {
    uploadCalls++;
    if (failNextUpload) {
      failNextUpload = false;
      throw const RemotePreconditionFailed();
    }
    snapshot = RemoteSnapshot(
      fileId: previous?.fileId ?? 'file-1',
      bytes: bytes,
      version: '$uploadCalls',
    );
  }
}
