import 'package:flutter/material.dart';
import 'package:hdpm/components/text/copyabletext.dart';

class MnemonicPassphraseSecretEditor extends StatelessWidget {
  MnemonicPassphraseSecretEditor({Key key, this.title, this.mnemonic, this.wordCount, this.onWordCountChanged})
      : super(key: key);

  final String title;
  final String mnemonic;
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
                  onChanged: (value) {
                    onWordCountChanged(value.toInt());
                  },
                ),
              ),
              Text(wordCount.toString()),
            ],
          ),
        ),
        CopyableText(title: title, subtitle: mnemonic),
      ],
    );
  }
}
