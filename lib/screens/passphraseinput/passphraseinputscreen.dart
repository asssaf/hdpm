import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/screens/passphraseinput/components/passphraseinputform.dart';
import 'package:hdpm/services/seedencryption.dart';
import 'package:hdpm/services/seedrepository.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';

final Logger _logger = Logger('PassphraseInput');

class PassphraseInputScreen extends StatefulWidget {
  PassphraseInputScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State createState() => _PassphraseInputState();
}

class _PassphraseInputState extends State<PassphraseInputScreen> {
  bool _processing = false;
  Uint8List _encryptedSeed;

  @override
  void initState() {
    super.initState();
    _loadEncryptedSeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder().build(
        context: context,
        title: widget.title,
        locked: true,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: PassphraseInputForm(onSave: _onSave, enabled: !_processing),
            ),
          );
        },
      ),
    );
  }

  void _loadEncryptedSeed() async {
    final encryptedSeed = await SeedRepository().fetchSeed();

    setState(() {
      _encryptedSeed = encryptedSeed;
    });
  }

  void _onSave(String passphrase) async {
    setState(() {
      _processing = true;
    });

    _logger.fine('Deriving key from passphrase');
    var key = await compute(_computeKey, passphrase);
    _logger.fine('Finished deriving key from passphrase');

    setState(() {
      _processing = false;
    });

    //TODO if still loading, wait

    if (_encryptedSeed == null) {
      Navigator.pushNamed(context, Routes.seedInput, arguments: key);
    } else {
      final seedBytes = SeedEncryption().decrypt(key, _encryptedSeed);
      final seed = BIP32.fromSeed(seedBytes);
      Navigator.pushNamedAndRemoveUntil(context, Routes.secretList, (_) => false, arguments: seed);
    }
  }

  static Uint8List _computeKey(String passphrase) {
    //TODO argon2 would be better (side channel attack resistant) but not supported by pointycastle
    KeyDerivator derivator = Scrypt();

    final N = 2048;
    final r = 8;
    final p = 1;
    final desiredKeySize = 32; // 32 byte key needed for aes256
    final salt = utf8.encode("hdpm.1560390267");

    derivator.init(ScryptParameters(N, r, p, desiredKeySize, salt));
    return derivator.process(utf8.encode(passphrase));
  }
}
