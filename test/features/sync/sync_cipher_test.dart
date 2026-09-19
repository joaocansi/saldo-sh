import 'dart:convert';
import 'dart:typed_data';

import 'package:saldo_sh/src/features/sync/security/sync_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cipher = SyncCipher(memory: 8192, iterations: 1);
  const password = 'uma-senha-forte-123';

  test('encrypts and decrypts with a unique nonce', () async {
    final material = await cipher.deriveNew(password);
    final clear = Uint8List.fromList(utf8.encode('dados financeiros'));
    final first = await cipher.encrypt(clear, material);
    final second = await cipher.encrypt(clear, material);

    final firstJson = jsonDecode(utf8.decode(first)) as Map<String, dynamic>;
    final secondJson = jsonDecode(utf8.decode(second)) as Map<String, dynamic>;
    expect(firstJson['cipher']['nonce'], isNot(secondJson['cipher']['nonce']));
    expect(
      utf8.decode(await cipher.decrypt(first, material)),
      'dados financeiros',
    );
  });

  test('wrong password and tampering never decrypt', () async {
    final material = await cipher.deriveNew(password);
    final encrypted = await cipher.encrypt(
      Uint8List.fromList(utf8.encode('snapshot')),
      material,
    );
    final wrong = await cipher.deriveFromEnvelope(
      'outra-senha-forte-456',
      encrypted,
    );
    await expectLater(cipher.decrypt(encrypted, wrong), throwsA(anything));

    final envelope = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
    final ciphertext = base64Decode(envelope['ciphertext'] as String);
    ciphertext[0] ^= 1;
    envelope['ciphertext'] = base64Encode(ciphertext);
    final tampered = Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
    await expectLater(cipher.decrypt(tampered, material), throwsA(anything));
  });
}
