import 'package:flutter/material.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:hdpm/components/text/copyabletext.dart';

class Bip32NodeDisplay extends StatefulWidget {
  Bip32NodeDisplay({Key key, @required this.node})
      : assert(node != null),
        super(key: key);

  final bip32.BIP32 node;

  @override
  _Bip32NodeState createState() => _Bip32NodeState();
}

class _Bip32NodeState extends State<Bip32NodeDisplay> {
  @override
  Widget build(BuildContext context) {
    var text = widget.node.toBase58();
    return Container(
      child: CopyableText(title: text),
    );
  }
}