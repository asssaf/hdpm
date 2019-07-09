import 'package:bip32/bip32.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/derivedsecretitemfieldpreview.dart';

class EditSecretForm extends StatefulWidget {
  EditSecretForm(
      {Key key, this.formKey, @required this.seed, @required this.secretItem, @required this.secretItemBuilder})
      : assert(seed != null),
        assert(secretItem != null),
        assert(secretItemBuilder != null),
        super(key: key);

  final GlobalKey<FormState> formKey;
  final BIP32 seed;
  final SecretItem secretItem;
  final SecretItemBuilder secretItemBuilder;

  @override
  State createState() => _EditSecretFormState();
}

class _EditSecretFormState extends State<EditSecretForm> {
  static const _itemBuilders = <Type, Function>{
    CustomSecretItemField.gtype: _customFieldBuilder,
    DerivedSecretItemField.gtype: _derivedFieldBuilder,
  };

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView.builder(
        itemCount: widget.secretItem.fields.length,
        itemBuilder: _itemBuilder(),
      ),
    );
  }

  IndexedWidgetBuilder _itemBuilder() {
    return (BuildContext context, int index) {
      final field = widget.secretItem.fields[index];
      final fieldBuilder = _itemBuilders[field.runtimeType];
      if (fieldBuilder == null) {
        throw Exception('Unsupported field type: ${field.runtimeType}');
      }
      return fieldBuilder(widget, field, (field) => widget.secretItemBuilder.fields[index] = field);
    };
  }

  static Widget _customFieldBuilder(
      EditSecretForm widget, CustomSecretItemField field, ValueChanged<SecretItemField> onChanged) {
    return ListTile(
      title: TextFormField(
        decoration: InputDecoration(
          labelText: field.name,
        ),
        initialValue: field.value,
        onSaved: (value) => onChanged(field.rebuild((b) => b.value = value)),
      ),
    );
  }

  static Widget _derivedFieldBuilder(
      EditSecretForm widget, DerivedSecretItemField field, ValueChanged<SecretItemField> onChanged) {
    return DerivedSecretItemFieldPreview(
      seed: widget.seed,
      secretItem: widget.secretItem,
      field: field,
      onChanged: onChanged,
    );
  }
}
