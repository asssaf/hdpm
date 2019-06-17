import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:hdpm/components/text/copyabletext.dart';
import 'package:hex/hex.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('MnemonicSecret');

class MnemonicSecret extends StatelessWidget {
  MnemonicSecret({Key key, this.secretStream, this.wordCount, this.onWordCountChanged}) : super(key: key);

  final Stream<Uint8List> secretStream;
  final int wordCount;
  final ValueChanged<int> onWordCountChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: Row(
            children: <Widget>[
              Text('Words'),
              Expanded(
                child: Slider(
                  label: wordCount.toString(),
                  value: wordCount.toDouble(),
                  min: 4,
                  max: 12,
                  divisions: 9,
                  onChanged: (value) => onWordCountChanged(value.toInt()),
                ),
              ),
              Text(wordCount.toString()),
            ],
          ),
        ),
        StreamBuilder(
          stream: secretStream.map(convert),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final words = snapshot.data.split(' ').sublist(0, wordCount).join(' ');
            return CopyableText(title: words);
          },
        ),
      ],
    );
  }

  static String convert(Uint8List secret) {
    if (secret == null) {
      return null;
    }

    _logger.finest('Starting secret');
    final String ent = HEX.encode(secret);
    final mnemonic = bip39.entropyToMnemonic(ent);
    _logger.finest('Finished secret');
    return mnemonic;
  }
}
