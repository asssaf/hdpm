import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem/mnemonicpassphrasesecretitemfieldtype.dart';
import 'package:hdpm/models/secretitem/passwordsecretitemfieldtype.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/derivedsecretitemfieldtypepreview.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/mnemonicpassphrasefieldtypeeditor.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/passwordfieldtypeeditor.dart';

class DerivedSecretItemFieldTypeEditor extends StatefulWidget {
  DerivedSecretItemFieldTypeEditor({Key key, this.secret, this.initialValue, this.onChanged}) : super(key: key);

  final Uint8List secret;
  final DerivedSecretItemFieldType initialValue;
  final ValueChanged<DerivedSecretItemFieldType> onChanged;

  @override
  State createState() => _DerivedSecretItemFieldTypeEditorState();
}

class _DerivedSecretItemFieldTypeEditorState extends State<DerivedSecretItemFieldTypeEditor> {
  DerivedSecretItemFieldType _fieldType;
  Future<String> _secretValue;

  final Map<String, DerivedSecretItemFieldType> _fieldTypes = Map.fromIterable(
    [
      MnemonicPassphraseSecretItemFieldType(),
      PasswordSecretItemFieldType(),
    ],
    key: (field) => field.name,
  );

  static final Map<String, Function> _fieldTypeEditors = {
    MnemonicPassphraseSecretItemFieldType().name: MnemonicPassphraseFieldTypeEditor.getInstance,
    PasswordSecretItemFieldType().name: PasswordFieldTypeEditor.getInstance,
  };

  @override
  void initState() {
    super.initState();
    _fieldType = widget.initialValue.clone();
    _fieldTypes[_fieldType.name] = _fieldType;
  }

  @override
  void didUpdateWidget(DerivedSecretItemFieldTypeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secret != widget.secret) {
      _updateSecretValue();
    }
  }

  void _updateSecretValue() {
    _secretValue = widget.secret != null ? _fieldType.deriveValue(widget.secret) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Text('Type'),
          title: DropdownButton<String>(
            value: _fieldType.name,
            onChanged: (value) {
              if (value != _fieldType.name) _fieldTypeChanged(_fieldTypes[value]);
            },
            items: _fieldTypes.keys
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
          ),
        ),
        _buildFieldTypeEditor(),
        DerivedSecretItemFieldTypePreview(
          title: 'Preview',
          fieldType: _fieldType,
          secretValue: _secretValue,
        ),
      ],
    );
  }

  Widget _buildFieldTypeEditor() {
    final factory = _fieldTypeEditors[_fieldType.name];
    if (factory == null) {
      throw Exception('Unexpected field type: ${_fieldType.runtimeType}');
    }
    return factory(_fieldType, _secretValue, _fieldTypeKnobsChanged);
  }

  void _fieldTypeChanged(DerivedSecretItemFieldType fieldType) {
    setState(() => _fieldType = fieldType);
    _updateSecretValue();
    widget.onChanged(fieldType);
  }

  void _fieldTypeKnobsChanged(DerivedSecretItemFieldType fieldType) {
    setState(() {
      _fieldType = fieldType;
      _fieldTypes[_fieldType.name] = fieldType;
    });
    widget.onChanged(fieldType);
  }
}
