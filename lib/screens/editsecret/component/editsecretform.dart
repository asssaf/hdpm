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
  bool _changed = false;

  static const _itemBuilders = <Type, Function>{
    CustomSecretItemField.gtype: _customFieldBuilder,
    DerivedSecretItemField.gtype: _derivedFieldBuilder,
  };

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      onChanged: () => setState(() => _changed = true),
      onWillPop: _onWillPop,
      child: ListView.builder(
        itemCount: widget.secretItem.fields.length,
        itemBuilder: _itemBuilder(),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_changed) {
      return true;
    }

    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unsaved Edit'),
          content: Text('Unsaved entry will be lost. Continue?'),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );

    return confirmed == true;
  }

  void _fieldChanged(int index, field) {
    if (widget.secretItem.fields[index] != field) {
      widget.secretItemBuilder.fields[index] = field;
      setState(() => _changed = true);
    }
  }

  IndexedWidgetBuilder _itemBuilder() {
    return (BuildContext context, int index) {
      final field = widget.secretItem.fields[index];
      final fieldBuilder = _itemBuilders[field.runtimeType];
      if (fieldBuilder == null) {
        throw Exception('Unsupported field type: ${field.runtimeType}');
      }
      return fieldBuilder(widget, field, (field) => _fieldChanged(index, field));
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
