import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hdpm/services/encryption.dart';

void main() {
  test('encryption is reversible', () {
    final hmacKey = Uint8List.fromList(List.filled(64, 0));
    final key = Uint8List.fromList(List.filled(16, 0));
    final data = Uint8List.fromList(List.filled(100, 1));
    final encryptedData = encrypt(null, hmacKey, key, data);

    expect(encryptedData, isNot(equals(data)));

    final decryptedData = decrypt(hmacKey, key, encryptedData);

    expect(decryptedData, equals(data));
  });

  test('encryption is not malleable', () {
    final hmacKey = Uint8List.fromList(List.filled(64, 0));
    final key = Uint8List.fromList(List.filled(16, 0));
    final data = Uint8List.fromList(List.filled(100, 1));
    final encryptedData = encrypt(null, hmacKey, key, data);

    encryptedData[5]++;

    expect(() => decrypt(hmacKey, key, encryptedData), throwsA(anything));
  });
}
