import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/digests/ripemd160.dart';

class DerivationPathGenerator {
  Future<String> textToPath(String text) async {
    return await compute(_computePath, text);
  }

  static String _computePath(String text) {
    // encode the title into a fixed number of bytes, this doesn't need to be cryptographically secure
    final digest = RIPEMD160Digest().process(Uint8List.fromList(text.codeUnits));

    // each path segment can encode 31 bits, we can encode 93 bits in 3 segments
    // which should be enough to make collisions unlikely
    final data = new ByteData.view(digest.buffer);
    var path = "m/1";

    for (int i = 0; i < 3; ++i) {
      // get 32 bits from the hash
      var index = data.getUint32(i * 4);

      // clear the top bit
      index &= ~(1 << 31);
      path += "/$index'";
    }

    return path;
  }
}
