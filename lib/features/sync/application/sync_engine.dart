import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../data/sync_snapshot_store.dart';
import '../domain/sync_models.dart';
import '../security/sync_cipher.dart';

class SyncEngine {
  SyncEngine(this._localStore, this._cipher, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final SyncSnapshotStore _localStore;
  final SyncCipher _cipher;
  final Uuid _uuid;

  Future<SyncMergeResult> synchronize({
    required DriveRemoteStore remoteStore,
    required SyncKeyMaterial key,
  }) async {
    RemoteSnapshot? remote;
    for (var attempt = 0; attempt < 3; attempt++) {
      remote = await remoteStore.download();
      var merge = const SyncMergeResult(changed: false, conflicts: 0);
      if (remote != null) {
        final clear = await _cipher.decrypt(remote.bytes, key);
        final decoded = jsonDecode(utf8.decode(clear));
        if (decoded is! Map) {
          throw const FormatException('Snapshot remoto inválido.');
        }
        merge = await _localStore.merge(Map<String, dynamic>.from(decoded));
      }
      final conflicts = await _localStore.readConflicts();
      if (conflicts.isNotEmpty) {
        return SyncMergeResult(
          changed: merge.changed,
          conflicts: conflicts.length,
        );
      }
      final snapshot = await _localStore.exportSnapshot();
      final encrypted = await _cipher.encrypt(
        Uint8List.fromList(utf8.encode(jsonEncode(snapshot))),
        key,
      );
      try {
        await remoteStore.upload(encrypted, previous: remote);
        return merge;
      } on RemotePreconditionFailed {
        if (attempt == 2) rethrow;
      }
    }
    throw const RemotePreconditionFailed();
  }

  Future<String> resetRemote({
    required DriveRemoteStore remoteStore,
    required SyncKeyMaterial key,
  }) async {
    final resetId = _uuid.v4();
    final clear = Uint8List.fromList(
      utf8.encode(jsonEncode(_localStore.emptyResetSnapshot(resetId))),
    );
    for (var attempt = 0; attempt < 3; attempt++) {
      final previous = await remoteStore.download();
      if (previous != null) {
        final existing = await _cipher.decrypt(previous.bytes, key);
        final decoded = jsonDecode(utf8.decode(existing));
        if (decoded is! Map ||
            (decoded['schemaVersion'] != 1 &&
                decoded['schemaVersion'] != 2 &&
                decoded['schemaVersion'] != 3)) {
          throw const FormatException('Snapshot remoto inválido.');
        }
      }
      final encrypted = await _cipher.encrypt(clear, key);
      try {
        await remoteStore.upload(encrypted, previous: previous);
        return resetId;
      } on RemotePreconditionFailed {
        if (attempt == 2) rethrow;
      }
    }
    throw const RemotePreconditionFailed();
  }
}
