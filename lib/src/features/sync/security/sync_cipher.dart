import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class SyncKeyMaterial {
  const SyncKeyMaterial({
    required this.key,
    required this.salt,
    required this.memory,
    required this.iterations,
    required this.parallelism,
  });

  final List<int> key;
  final List<int> salt;
  final int memory;
  final int iterations;
  final int parallelism;

  Map<String, dynamic> toJson() => {
    'key': base64Encode(key),
    'salt': base64Encode(salt),
    'memory': memory,
    'iterations': iterations,
    'parallelism': parallelism,
  };

  factory SyncKeyMaterial.fromJson(Map<String, dynamic> json) =>
      SyncKeyMaterial(
        key: base64Decode(json['key'] as String),
        salt: base64Decode(json['salt'] as String),
        memory: json['memory'] as int,
        iterations: json['iterations'] as int,
        parallelism: json['parallelism'] as int,
      );
}

class SyncCipher {
  SyncCipher({this.memory = 19456, this.iterations = 2, this.parallelism = 1});

  final int memory;
  final int iterations;
  final int parallelism;
  final AesGcm _cipher = AesGcm.with256bits();

  Future<SyncKeyMaterial> deriveNew(String password) async {
    _validatePassword(password);
    final salt = _randomBytes(16);
    return SyncKeyMaterial(
      key: await _derive(password, salt, memory, iterations, parallelism),
      salt: salt,
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
    );
  }

  Future<SyncKeyMaterial> deriveFromEnvelope(
    String password,
    Uint8List encrypted,
  ) async {
    _validatePassword(password);
    final envelope = _decodeEnvelope(encrypted);
    final kdf = Map<String, dynamic>.from(envelope['kdf'] as Map);
    final salt = base64Decode(kdf['salt'] as String);
    final selectedMemory = kdf['memory'] as int;
    final selectedIterations = kdf['iterations'] as int;
    final selectedParallelism = kdf['parallelism'] as int;
    _validateParameters(
      selectedMemory,
      selectedIterations,
      selectedParallelism,
    );
    return SyncKeyMaterial(
      key: await _derive(
        password,
        salt,
        selectedMemory,
        selectedIterations,
        selectedParallelism,
      ),
      salt: salt,
      memory: selectedMemory,
      iterations: selectedIterations,
      parallelism: selectedParallelism,
    );
  }

  Future<Uint8List> encrypt(
    Uint8List clearText,
    SyncKeyMaterial material,
  ) async {
    final nonce = _randomBytes(12);
    final box = await _cipher.encrypt(
      clearText,
      secretKey: SecretKey(material.key),
      nonce: nonce,
    );
    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'version': 1,
          'kdf': {
            'name': 'argon2id',
            'salt': base64Encode(material.salt),
            'memory': material.memory,
            'iterations': material.iterations,
            'parallelism': material.parallelism,
          },
          'cipher': {'name': 'aes-256-gcm', 'nonce': base64Encode(nonce)},
          'ciphertext': base64Encode(box.cipherText),
          'mac': base64Encode(box.mac.bytes),
        }),
      ),
    );
  }

  Future<Uint8List> decrypt(
    Uint8List encrypted,
    SyncKeyMaterial material,
  ) async {
    final envelope = _decodeEnvelope(encrypted);
    final kdf = Map<String, dynamic>.from(envelope['kdf'] as Map);
    if (base64Encode(material.salt) != kdf['salt']) {
      throw SecretBoxAuthenticationError();
    }
    final cipher = Map<String, dynamic>.from(envelope['cipher'] as Map);
    final box = SecretBox(
      base64Decode(envelope['ciphertext'] as String),
      nonce: base64Decode(cipher['nonce'] as String),
      mac: Mac(base64Decode(envelope['mac'] as String)),
    );
    return Uint8List.fromList(
      await _cipher.decrypt(box, secretKey: SecretKey(material.key)),
    );
  }

  Map<String, dynamic> _decodeEnvelope(Uint8List encrypted) {
    if (encrypted.length > 50 * 1024 * 1024) {
      throw const FormatException('Snapshot acima do limite.');
    }
    final decoded = jsonDecode(utf8.decode(encrypted));
    if (decoded is! Map || decoded['version'] != 1) {
      throw const FormatException('Arquivo de sincronização inválido.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<List<int>> _derive(
    String password,
    List<int> salt,
    int memory,
    int iterations,
    int parallelism,
  ) async {
    final algorithm = Argon2id(
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: 32,
    );
    final key = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return key.extractBytes();
  }

  void _validatePassword(String value) {
    if (value.length < 12 || value.length > 256) {
      throw const FormatException(
        'A senha deve ter entre 12 e 256 caracteres.',
      );
    }
  }

  void _validateParameters(int memory, int iterations, int parallelism) {
    if (memory < 8192 ||
        memory > 131072 ||
        iterations < 1 ||
        iterations > 10 ||
        parallelism < 1 ||
        parallelism > 4) {
      throw const FormatException('Parâmetros criptográficos inválidos.');
    }
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
