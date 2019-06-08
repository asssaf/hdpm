import 'package:flutter/material.dart';
import 'package:hdpm/components/bip32node/bip32nodedisplay.dart';
import 'package:hdpm/screens/derivepath/components/pathinputform.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';

class DerivePathScreen extends StatefulWidget {
  DerivePathScreen({Key key, this.title, this.seed}) : super(key: key);

  final String title;
  final String seed;

  @override
  _DerivePathScreenState createState() => _DerivePathScreenState();
}

class _DerivePathScreenState extends State<DerivePathScreen> {
  bip32.BIP32 _derivedNode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          children: [
            PathInputForm(onSave: onSave),
            _derivedNode != null ? Bip32NodeDisplay(node: _derivedNode) : Container(),
          ],
        ),
      ),//SeedInputForm(),
    );
  }

  void onSave(String path) {
    bip32.BIP32 nodeFromSeed = bip32.BIP32.fromSeed(HEX.decode(widget.seed));
    bip32.BIP32 child = nodeFromSeed.derivePath(path);
    setState(() {
      _derivedNode = child;
    });
  }
}