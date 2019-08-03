import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/appstatecontainer.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/screens/passphraseinput/components/passphraseinputform.dart';
import 'package:hdpm/services/encryption.dart';
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
              child: PassphraseInputForm(onSave: (passphrase) => _onSave(passphrase, context), enabled: !_processing),
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

  void _onSave(String passphrase, BuildContext context) async {
    setState(() {
      _processing = true;
    });

    _logger.fine('Deriving key from passphrase');
    var seedEncryptionKey = await compute(_computeKey, passphrase);
    _logger.fine('Finished deriving key from passphrase');

    setState(() {
      _processing = false;
    });

    //TODO if still loading, wait

    if (_encryptedSeed == null) {
      Navigator.pushNamed(context, Routes.seedInput, arguments: seedEncryptionKey);
    } else {
      try {
        final seedBytes = decrypt(seedEncryptionKey, _encryptedSeed);
        final seed = BIP32.fromSeed(seedBytes);

        await AppStateContainer.of(context).state.openSecretStore(seed: seed);
        Navigator.pushNamedAndRemoveUntil(context, Routes.secretList, (_) => false, arguments: seed);
      } catch (error) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Failed to load metadata, please try again')));
      }
    }
  }

  static EncryptionKey _computeKey(String passphrase) {
    //TODO argon2 would be better (side channel attack resistant) but not supported by pointycastle
    KeyDerivator derivator = Scrypt();

    final N = 2048;
    final r = 8;
    final p = 1;
    final desiredKeySize = 64; // 32 byte key needed for aes256 and another 32 bytes for the HMAC key
    final salt = utf8.encode("hdpm.1560390267");

    derivator.init(ScryptParameters(N, r, p, desiredKeySize, salt));
    return EncryptionKey.split(derivator.process(utf8.encode(passphrase)));
  }
}
