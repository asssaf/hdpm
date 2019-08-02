import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';

const _FORMAT_VERSION = 0;
const _IV_LENGTH = 16;
const _HMAC_LEN = 32;

/// encrypt data with the given IV and key
/// the returned data includes the IV and an authentication tag which are used in the decrypt function
/// hmacKey is the key used in HMAC-SHA256, the recommended key size is 64-byte (although a 32-byte full
/// entropy key should suffice) and must be unrelated to the encryption key
Uint8List encrypt(Uint8List iv, Uint8List hmacKey, Uint8List key, Uint8List data) {
  assert(hmacKey != key);

  final actualIv = iv ?? generateRandomIV(_IV_LENGTH);
  final cipher = _getCipher(true, actualIv, key);

  final encryptedData = cipher.process(data);
  final hmac = Hmac(sha256, hmacKey);

  final preHmac = [_FORMAT_VERSION] + actualIv + encryptedData;
  final hmacTag = hmac.convert(preHmac).bytes;

  final encryptedBlob = Uint8List.fromList(preHmac + hmacTag);

  return encryptedBlob;
}

Uint8List decrypt(Uint8List hmacKey, Uint8List key, Uint8List encryptedBlob) {
  final formatVersion = encryptedBlob[0];
  if (formatVersion != _FORMAT_VERSION) {
    throw Exception('Unsupported format version: $formatVersion');
  }

  final hmacIndex = encryptedBlob.length - _HMAC_LEN;
  final iv = encryptedBlob.sublist(1, _IV_LENGTH + 1);
  final encryptedData = encryptedBlob.sublist(_IV_LENGTH + 1, hmacIndex);
  final hmacTag = encryptedBlob.sublist(hmacIndex);

  final hmac = Hmac(sha256, hmacKey);
  final preHmac = [_FORMAT_VERSION] + iv + encryptedData;
  final calculatedHmacTag = hmac.convert(preHmac).bytes;

  if (!listEquals(hmacTag, calculatedHmacTag)) {
    throw Exception('Encrypted data authentication failed');
  }

  final cipher = _getCipher(false, iv, key);

  return cipher.process(encryptedData);
}

Uint8List generateRandomIV(int length) {
  // generate random IV (this relies on the platform which may be buggy!)
  final r = Random.secure();
  final iv = Uint8List(length);
  for (int i = 0; i < length; ++i) {
    iv[i] = r.nextInt(256);
  }

  return iv;
}

BlockCipher _getCipher(bool encryption, Uint8List iv, Uint8List key) {
  // pointycastle has a disappointingly small choice of algorithms
  // SALSA20 only has 64 bit nonce which is too short for using a random (XSALSA20 is not available)
  // AES/CTR would be good but fails catastrophically on nonce reuse, so we'd have to trust the system PRNG
  // AES/CBC/PKCS7 seems to be the best option, but we need to EtM to protect against chosen ciphertext attacks
  final cipherParams = ParametersWithIV(new KeyParameter(key), iv);
  final params = PaddedBlockCipherParameters(cipherParams, null);
  final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
  cipher.init(encryption, params);
  return cipher;
}
