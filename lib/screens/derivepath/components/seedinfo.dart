import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/services/seedrepository.dart';
import 'package:hex/hex.dart';

class SeedInfo extends StatefulWidget {
  SeedInfo({Key key, this.seed}) : super(key: key);

  final BIP32 seed;

  @override
  State createState() => _SeedInfoState();
}

class _SeedInfoState extends State<SeedInfo> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Seed Fingerprint'),
      subtitle: Text(HEX.encode(widget.seed.fingerprint)),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: _deleteSeed,
      ),
    );
  }

  void _deleteSeed() async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Seed'),
          content: Text('Seed will be removed permanently and all existing keys will be lost. Continue?'),
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
      final result = await SeedRepository().deleteSeed();
      if (!result) {
        _showError('Failed to delete the seed');
      } else {
        Navigator.pushNamedAndRemoveUntil(context, Routes.initial, (_) => false);
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to delete seed'),
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
