import 'dart:typed_data';

enum SyncStatus {
  disconnected,
  syncing,
  synced,
  pending,
  conflict,
  error,
  resetting,
}

class RemoteSnapshot {
  const RemoteSnapshot({
    required this.fileId,
    required this.bytes,
    required this.version,
  });

  final String fileId;
  final Uint8List bytes;
  final String version;
}

class SyncMergeResult {
  const SyncMergeResult({required this.changed, required this.conflicts});
  final bool changed;
  final int conflicts;
}

abstract interface class DriveRemoteStore {
  Future<RemoteSnapshot?> download();
  Future<void> upload(Uint8List bytes, {RemoteSnapshot? previous});
}

class RemotePreconditionFailed implements Exception {
  const RemotePreconditionFailed();
}
