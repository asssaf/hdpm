import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:quiver/collection.dart';

class SecretDeriver {
  static final SecretDeriver _instance = SecretDeriver._();

  final Map _cache = LruMap(maximumSize: 10);

  SecretDeriver._();

  factory SecretDeriver() {
    return _instance;
  }

  Future<Uint8List> deriveSecret(BIP32 seed, String path) async {
    final input = _PathDerivationInput(seed, path);
    final cachedResult = await _cache[input];
    if (cachedResult != null) {
      return cachedResult;
    }

    final node = await compute(_derivePath, input);

    // append the path to the private key (in case an index is skipped by derivation)
    final prehash = node.privateKey + path.codeUnits;

    final hashed = sha256.newInstance().convert(prehash).bytes;
    _cache[input] = hashed;

    return hashed;
  }

  static BIP32 _derivePath(_PathDerivationInput input) {
    final node = input.seed.derivePath(input.path);

    return node;
  }
}

// input for the _derivePath compute function
class _PathDerivationInput {
  _PathDerivationInput(this.seed, this.path);

  final BIP32 seed;
  final String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PathDerivationInput && runtimeType == other.runtimeType && seed == other.seed && path == other.path;

  @override
  int get hashCode => seed.hashCode ^ path.hashCode;
}
