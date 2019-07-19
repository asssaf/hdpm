import 'dart:math';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:pointycastle/api.dart';

final Logger _logger = Logger('SeedEncryption');

/// encrypt the seed using AES without authentication (decrypting with different keys
/// will return different seeds)
class SeedEncryption {
  Uint8List encrypt(Uint8List seedEncryptionKey, Uint8List seed) {
    _logger.fine('Encrypting');

    // generate 16 byte random IV
    final iv = _generateRandomIV(16);
    final params = ParametersWithIV(KeyParameter(seedEncryptionKey), iv);

    // no need for padding as we are encryption 64 bytes which is a multiple of the block size
    assert(seed.lengthInBytes == 64);
    final cipher = StreamCipher('AES/CTR');
    cipher.init(true, params);
    final encryptedSeed = Uint8List.fromList(iv + cipher.process(seed));
    _logger.fine('Finished encrypting');
    return encryptedSeed;
  }

  Uint8List decrypt(Uint8List seedEncryptionKey, Uint8List encryptedSeed) {
    _logger.fine('Decrypting');
    final iv = Uint8List.view(encryptedSeed.buffer, 0, 16);
    final enc = Uint8List.view(encryptedSeed.buffer, 16);

    // no need for padding as we are encryption 64 bytes which is a multiple of the block size
    assert(enc.lengthInBytes == 64);
    final params = ParametersWithIV(new KeyParameter(seedEncryptionKey), iv);
    final cipher = StreamCipher('AES/CTR');
    cipher.init(false, params);
    final seed = cipher.process(enc);
    _logger.fine('Finished decrypting');
    return seed;
  }

  Uint8List _generateRandomIV(int length) {
    // generate random IV
    final r = Random.secure();
    final iv = Uint8List(length);
    for (int i = 0; i < length; ++i) {
      iv[i] = r.nextInt(256);
    }

    return iv;
  }
}
