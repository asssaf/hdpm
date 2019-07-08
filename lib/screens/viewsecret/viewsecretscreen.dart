import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/appstatecontainer.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/components/text/copyabletext.dart';
import 'package:hdpm/models/secretitem.dart';
import 'package:hdpm/routes.dart';

class ViewSecretScreen extends StatelessWidget {
  ViewSecretScreen({Key key, this.title, this.seed, this.secretItem}) : super(key: key);

  final String title;
  final SecretItem secretItem;
  final BIP32 seed;

  static const _itemBuilders = <Type, Function>{
    CustomSecretItemField: _customFieldBuilder,
    MnemonicPassphraseSecretItemField: _derivedFieldBuilder,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder().action(_buildDeleteAction(context)).build(
            context: context,
            title: title,
          ),
      body: ListView.builder(
        itemCount: secretItem.fields.length,
        itemBuilder: _itemBuilder(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () => _edit(context),
      ),
    );
  }

  Widget _buildDeleteAction(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () => _delete(context),
    );
  }

  IndexedWidgetBuilder _itemBuilder() {
    return (BuildContext context, index) {
      final field = secretItem.fields[index];
      final fieldBuilder = _itemBuilders[field.runtimeType];
      return fieldBuilder(context, field);
    };
  }

  static Widget _customFieldBuilder(BuildContext context, CustomSecretItemField field) {
    return CopyableText(
      title: field.name,
      subtitle: field.value ?? '',
      enabled: field.value.isNotEmpty,
    );
  }

  static Widget _derivedFieldBuilder(BuildContext context, MnemonicPassphraseSecretItemField field) {
    final ViewSecretScreen widget = context.ancestorWidgetOfExactType(ViewSecretScreen);
    return FutureBuilder(
      future: field.deriveSecret(widget.seed).then(field.deriveValue),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var data;
        bool enabled = false;
        if (snapshot.hasError) {
          data = 'Error';
        } else if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          data = 'Calculating...';
        } else {
          data = field.deriveFinalValue(snapshot.data);
          enabled = true;
        }

        return CopyableText(
          title: field.name,
          subtitle: data ?? '',
          enabled: enabled,
        );
      },
    );
  }

  void _edit(context) {
    Navigator.pushNamed(context, Routes.editSecret, arguments: {"seed": seed, "secretItem": secretItem});
  }

  void _delete(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Secret'),
          content: Text('Secret metadata will be removed permanently. Continue?'),
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

    if (confirmed == true) {
      final secretRepository = AppStateContainer.of(context).state.secretRepository;
      final result = await secretRepository.delete(secretItem);
      if (result == true) {
        Navigator.pop(context, 'Deleted');
      } else {
        _showError(context);
      }
    }
  }

  void _showError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to delete secret'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
          ],
        );
      },
    );
  }
}
