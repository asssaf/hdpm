import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = Logger('SeedRepository');

/// fetch and store encrypted seeds in SharedPreferences
/// this doesn't handle encryption/decryption
class SeedRepository {
  static const SEED_PREF_KEY = 'encrypted_seed';
  static const int VERSION = 0;

  Future<Uint8List> fetchSeed() async {
    _logger.fine("Loading seed from prefs");
    final prefs = await SharedPreferences.getInstance();

    final encryptedSeed = prefs.getString(SEED_PREF_KEY);
    if (encryptedSeed == null) {
      _logger.fine('Seed not found in prefs');
      return null;
    } else {
      _logger.fine('Loaded seed from prefs');
      return _decodeVersion(HEX.decode(encryptedSeed));
    }
  }

  Future<bool> saveSeed(Uint8List encryptedSeed) async {
    _logger.fine('Saving seed in prefs');
    final prefs = await SharedPreferences.getInstance();

    final encoded = HEX.encode(_encodeVersion(encryptedSeed));
    final result = await prefs.setString(SEED_PREF_KEY, encoded);

    _logger.fine('Finished saving seed in prefs - result: $result');

    return result;
  }

  Future<bool> deleteSeed() async {
    _logger.fine('Deleting seed from prefs');
    final prefs = await SharedPreferences.getInstance();

    final result = await prefs.remove(SEED_PREF_KEY);

    _logger.fine('Finished deleting seed from prefs - result: $result');

    return result;
  }

  Uint8List _encodeVersion(Uint8List encrypted) {
    return Uint8List.fromList([VERSION] + encrypted);
  }

  Uint8List _decodeVersion(Uint8List versioned) {
    if (versioned[0] != VERSION) {
      _logger.warning('Unsupported version or corrupt seed: ${versioned[0]}');
      return null;
    }

    return versioned.sublist(1);
  }
}
