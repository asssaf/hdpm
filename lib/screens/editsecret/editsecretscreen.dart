import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/screens/editsecret/component/editsecretform.dart';

class EditSecretScreen extends StatefulWidget {
  EditSecretScreen({
    Key key,
    this.title,
    @required this.seed,
  })  : assert(seed != null),
        super(key: key);

  final String title;
  final BIP32 seed;

  @override
  State createState() => _EditSecretState();
}

class _EditSecretState extends State<EditSecretScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder().build(
        context: context,
        title: widget.title,
        locked: true,
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: EditSecretForm(seed: widget.seed),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
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
}
