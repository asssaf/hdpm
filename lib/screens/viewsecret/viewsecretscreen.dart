import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/appstatecontainer.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/models/secretitem.dart';

class ViewSecretScreen extends StatelessWidget {
  ViewSecretScreen({Key key, this.title, this.seed, this.secretItem}) : super(key: key);

  final String title;
  final SecretItem secretItem;
  final BIP32 seed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder().action(_buildDeleteAction(context)).build(
            context: context,
            title: title,
          ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: Container(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeleteAction(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () => _delete(context),
    );
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
        Navigator.pop(context);
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
