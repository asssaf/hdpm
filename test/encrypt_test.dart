import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hdpm/services/encryption.dart';

void main() {
  test('encryption is reversible', () {
    final hmacKey = Uint8List.fromList(List.filled(64, 0));
    final key = Uint8List.fromList(List.filled(16, 0));
    final encryptionKey = EncryptionKey(hmacKey: hmacKey, key: key);
    final data = Uint8List.fromList(List.filled(100, 1));
    final encryptedData = encrypt(null, encryptionKey, data);

    expect(encryptedData, isNot(equals(data)));

    final decryptedData = decrypt(encryptionKey, encryptedData);

    expect(decryptedData, equals(data));
  });

  test('encryption is not malleable', () {
    final hmacKey = Uint8List.fromList(List.filled(64, 0));
    final key = Uint8List.fromList(List.filled(16, 0));
    final encryptionKey = EncryptionKey(hmacKey: hmacKey, key: key);
    final data = Uint8List.fromList(List.filled(100, 1));
    final encryptedData = encrypt(null, encryptionKey, data);

    encryptedData[5]++;

    expect(() => decrypt(encryptionKey, encryptedData), throwsA(anything));
  });
}
