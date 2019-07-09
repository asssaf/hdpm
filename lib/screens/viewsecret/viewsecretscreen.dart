import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/appstatecontainer.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/components/text/copyabletext.dart';
import 'package:hdpm/models/screenresult.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/derivedsecretitemfieldpreview.dart';
import 'package:hdpm/services/secretrepository.dart';

class ViewSecretScreen extends StatelessWidget {
  ViewSecretScreen({Key key, this.title, this.seed, this.secretItem}) : super(key: key);

  final String title;
  final SecretItem secretItem;
  final BIP32 seed;

  static const _itemBuilders = <Type, Function>{
    CustomSecretItemField.gtype: _customFieldBuilder,
    DerivedSecretItemField.gtype: _derivedFieldBuilder,
  };

  @override
  Widget build(BuildContext context) {
    final SecretRepository _secretRepository = AppStateContainer.of(context).state.secretRepository;
    _secretRepository.findByPath(secretItem.path);

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
      if (fieldBuilder == null) {
        throw Exception('Unsupported field type: ${field.runtimeType}');
      }
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

  static Widget _derivedFieldBuilder(BuildContext context, DerivedSecretItemField field) {
    final ViewSecretScreen widget = context.ancestorWidgetOfExactType(ViewSecretScreen);

    return DerivedSecretItemFieldPreview(
      seed: widget.seed,
      secretItem: widget.secretItem,
      field: field,
    );
  }

  void _edit(context) async {
    final result =
        await Navigator.pushNamed(context, Routes.editSecret, arguments: {"seed": seed, "secretItem": secretItem});
    if (result is ScreenResult) {
      Navigator.pushReplacementNamed(context, Routes.viewSecret,
          arguments: {"seed": seed, "secretItem": result.result});
    }
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
        Navigator.pop(context, ScreenResult(message: 'Deleted', result: secretItem));
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
