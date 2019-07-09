import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem/mnemonicpassphrasesecretitemfieldtype.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/labeledintslider.dart';

class MnemonicPassphraseFieldTypeEditor extends StatefulWidget {
  MnemonicPassphraseFieldTypeEditor({Key key, this.fieldType, this.secretValue, this.onChanged}) : super(key: key);

  final MnemonicPassphraseSecretItemFieldType fieldType;
  final Future<String> secretValue;
  final ValueChanged<DerivedSecretItemFieldType> onChanged;

  @override
  State createState() => _MnemonicPassphraseFieldTypeEditorState();

  static Widget getInstance(fieldType, secretValue, onChanged) =>
      MnemonicPassphraseFieldTypeEditor(fieldType: fieldType, secretValue: secretValue, onChanged: onChanged);
}

class _MnemonicPassphraseFieldTypeEditorState extends State<MnemonicPassphraseFieldTypeEditor> {
  int _wordCount;

  @override
  void initState() {
    super.initState();
    _wordCount = widget.fieldType.wordCount;
  }

  @override
  void didUpdateWidget(MnemonicPassphraseFieldTypeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldType.wordCount != widget.fieldType.wordCount) {
      _wordCount = widget.fieldType.wordCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabeledIntSlider(
      label: 'Words',
      value: _wordCount,
      min: 4,
      max: 12,
      onChanged: (value) {
        setState(() => _wordCount = value);
        widget.onChanged(widget.fieldType.rebuild((b) => b.wordCount = _wordCount));
      },
    );
  }
}
