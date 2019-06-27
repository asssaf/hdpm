import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/material.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/components/bip32node/bip32nodedisplay.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/screens/derivepath/components/pathinputform.dart';
import 'package:hdpm/screens/derivepath/components/seedinfo.dart';

class DerivePathScreen extends StatefulWidget {
  DerivePathScreen({Key key, this.title, this.seed}) : super(key: key);

  final String title;
  final bip32.BIP32 seed;

  @override
  _DerivePathScreenState createState() => _DerivePathScreenState();
}

class _DerivePathScreenState extends State<DerivePathScreen> {
  bip32.BIP32 _derivedNode;
  bool _neutered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder().build(
        context: context,
        title: widget.title,
      ),
      body: Column(
        children: [
          SeedInfo(seed: widget.seed),
          PathInputForm(onSave: _onSave),
          _buildNodeDisplay(_derivedNode),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _newItem(),
      ),
    );
  }

  Widget _buildNodeDisplay(bip32.BIP32 node) {
    if (node == null) {
      return Container();
    }

    return Expanded(
      child: Column(
        children: <Widget>[
          SwitchListTile(
            title: Text('Neutered'),
            value: _neutered,
            onChanged: _toggleNeutered,
          ),
          Expanded(child: Bip32NodeDisplay(node: _neutered ? node.neutered() : node)),
        ],
      ),
    );
  }

  void _toggleNeutered(bool val) {
    setState(() {
      _neutered = val;
    });
  }

  void _onSave(String path) {
    try {
      bip32.BIP32 child = widget.seed.derivePath(path);
      setState(() {
        _derivedNode = child;
      });

      // hide keyboard so the key view is not obscured
      FocusScope.of(context).requestFocus(new FocusNode());
    } on ArgumentError catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid path'),
            content: Text(e.message),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _newItem() {
    Navigator.pushNamed(context, Routes.editSecret, arguments: {'seed': widget.seed});
  }
}
