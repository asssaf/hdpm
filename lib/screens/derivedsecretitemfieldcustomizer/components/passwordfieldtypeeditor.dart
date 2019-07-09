import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem/passwordsecretitemfieldtype.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/labeledintslider.dart';

class PasswordFieldTypeEditor extends StatefulWidget {
  PasswordFieldTypeEditor({Key key, this.fieldType, this.secretValue, this.onChanged}) : super(key: key);

  final PasswordSecretItemFieldType fieldType;
  final Future<String> secretValue;
  final ValueChanged<DerivedSecretItemFieldType> onChanged;

  @override
  State createState() => _PasswordFieldTypeEditorState();

  static Widget getInstance(fieldType, secretValue, onChanged) =>
      PasswordFieldTypeEditor(fieldType: fieldType, secretValue: secretValue, onChanged: onChanged);
}

class _PasswordFieldTypeEditorState extends State<PasswordFieldTypeEditor> {
  int _length;

  @override
  void initState() {
    super.initState();
    _length = widget.fieldType.length;
  }

  @override
  void didUpdateWidget(PasswordFieldTypeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldType.length != widget.fieldType.length) {
      _length = widget.fieldType.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabeledIntSlider(
      label: 'Length',
      value: _length,
      min: 4,
      max: 16,
      onChanged: (value) {
        setState(() => _length = value);
        widget.onChanged(widget.fieldType.rebuild((b) => b.length = _length));
      },
    );
  }
}
