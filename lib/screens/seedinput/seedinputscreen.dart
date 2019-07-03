import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/screens/seedinput/components/seedinputform.dart';
import 'package:hdpm/services/seedencryption.dart';
import 'package:hdpm/services/seedrepository.dart';

class SeedInputScreen extends StatefulWidget {
  SeedInputScreen({
    Key key,
    this.title,
    @required this.seedEncryptionKey,
  })  : assert(seedEncryptionKey != null),
        super(key: key);

  final String title;
  final Uint8List seedEncryptionKey;

  @override
  _SeedInputScreenState createState() => _SeedInputScreenState();
}

class _SeedInputScreenState extends State<SeedInputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder().build(
        context: context,
        title: widget.title,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: SeedInputForm(onSave: _save),
            ),
          );
        },
      ),
    );
  }

  void _save(Uint8List seedBytes) async {
    // store encrypted seed in SharedPreferences
    final encryptedSeed = SeedEncryption().encrypt(widget.seedEncryptionKey, seedBytes);
    SeedRepository().saveSeed(encryptedSeed);

    final seed = BIP32.fromSeed(seedBytes);

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.secretList,
      (_) => false,
      arguments: seed,
    );
  }
}
