import 'dart:convert';
import 'dart:typed_data';

import '../../../core/security/secret_store.dart';
import 'sync_cipher.dart';

class SyncKeyManager {
  SyncKeyManager(this._secretStore, this._cipher);

  final SecretStore _secretStore;
  final SyncCipher _cipher;

  Future<bool> get hasKey async =>
      (await _secretStore.read(SecretKeys.syncEncryptionKey))?.isNotEmpty ==
      true;

  Future<SyncKeyMaterial> create(String password) async {
    final material = await _cipher.deriveNew(password);
    await _save(material);
    return material;
  }

  Future<SyncKeyMaterial> unlock(String password, Uint8List encrypted) async {
    final material = await _cipher.deriveFromEnvelope(password, encrypted);
    await _cipher.decrypt(encrypted, material);
    await _save(material);
    return material;
  }

  Future<SyncKeyMaterial?> read() async {
    final raw = await _secretStore.read(SecretKeys.syncEncryptionKey);
    if (raw == null || raw.isEmpty) return null;
    return SyncKeyMaterial.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> clear() => _secretStore.delete(SecretKeys.syncEncryptionKey);

  Future<void> _save(SyncKeyMaterial material) => _secretStore.write(
    SecretKeys.syncEncryptionKey,
    jsonEncode(material.toJson()),
  );
}
