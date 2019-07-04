import 'package:bip32/bip32.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/components/text/copyabletext.dart';
import 'package:hdpm/models/secretitem.dart';
import 'package:hdpm/screens/editsecret/component/derivedsecretitemffieldormfield.dart';

class EditSecretForm extends StatefulWidget {
  EditSecretForm({Key key, this.formKey, @required this.seed, @required this.secretItem})
      : assert(seed != null),
        assert(secretItem != null),
        super(key: key);

  final GlobalKey<FormState> formKey;
  final BIP32 seed;
  final SecretItem secretItem;

  @override
  State createState() => _EditSecretFormState();
}

class _EditSecretFormState extends State<EditSecretForm> {
  static const _itemBuilders = <Type, Function>{
    CustomSecretItemField: _customFieldBuilder,
    MnemonicPassphraseSecretItemField: _derivedFieldBuilder,
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
      return fieldBuilder(context, field);
    };
  }

  static Widget _customFieldBuilder(BuildContext context, CustomSecretItemField field) {
    return ListTile(
      title: TextFormField(
        decoration: InputDecoration(
          labelText: field.name,
        ),
        initialValue: field.value,
        onSaved: (value) => field.value = value,
      ),
    );
  }

  static Widget _derivedFieldBuilder(BuildContext context, MnemonicPassphraseSecretItemField field) {
    final EditSecretForm widget = context.ancestorWidgetOfExactType(EditSecretForm);
    final _EditSecretFormState state = context.ancestorStateOfType(TypeMatcher<_EditSecretFormState>());
    return FutureBuilder(
      future: field.deriveSecret(widget.seed).then(field.deriveValue),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var data;
        if (snapshot.hasError) {
          data = 'Error';
          return CopyableText(
            title: field.name,
            subtitle: data ?? '',
            enabled: false,
          );
        } else if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          data = 'Calculating...';
          return CopyableText(
            title: field.name,
            subtitle: data ?? '',
            enabled: false,
          );
        } else {
          data = snapshot.data;
        }

        //TODO prevent copying while calculating
        return DerivedSecretItemFieldFormField(
          initialValue: field,
          mnemonic: data,
          onSaved: (value) {
            field.wordCount = value.wordCount;
          },
        );
      },
    );
  }
}
