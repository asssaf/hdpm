import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/material.dart';
import 'package:hdpm/components/text/copyabletext.dart';
import 'package:hex/hex.dart';

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
    var node = widget.node;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            labelColor: Theme.of(context).accentColor,
            tabs: [
              Tab(text: 'Base58'),
              Tab(text: 'Hex'),
              Tab(text: 'Fingerprint'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTab(node.toBase58()),
            _buildTab(HEX.encode(node.isNeutered() ? node.publicKey : node.privateKey)),
            _buildTab(HEX.encode(node.fingerprint)),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return CopyableText(subtitle: text);
  }
}
