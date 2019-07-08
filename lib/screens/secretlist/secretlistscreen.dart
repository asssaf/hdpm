import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/material.dart';
import 'package:hdpm/appstatecontainer.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/models/secretitem.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/services/secretrepository.dart';
import 'package:hex/hex.dart';

class SecretListScreen extends StatefulWidget {
  SecretListScreen({Key key, this.title, this.seed}) : super(key: key);

  final String title;
  final bip32.BIP32 seed;

  @override
  State createState() => _SecretListState();
}

class _SecretListState extends State<SecretListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SecretRepository _secretRepository = AppStateContainer.of(context).state.secretRepository;

    final titleWithFingerprint = '${widget.title} (${HEX.encode(widget.seed.fingerprint)})';

    return Scaffold(
      appBar: AppBarBuilder().action(_buildInfoAction()).build(
            context: context,
            title: titleWithFingerprint,
          ),
      body: StreamBuilder(
        stream: _secretRepository.findAll(),
        builder: (context, AsyncSnapshot<List<SecretItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading');
          }

          if (snapshot.hasError) {
            return Text('Error');
          }

          if (!snapshot.hasData || snapshot.data.length == 0) {
            return Center(child: Text('No items'));
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                child: ListTile(title: Text(snapshot.data[index].title)),
                onTap: () => _viewItem(context, snapshot.data[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _newItem(context),
            ),
      ),
    );
  }

  Widget _buildInfoAction() {
    return IconButton(
      icon: Icon(Icons.info_outline),
      onPressed: () => Navigator.pushNamed(context, Routes.derivePath, arguments: widget.seed),
    );
  }

  void _newItem(BuildContext context) async {
    final result = await Navigator.pushNamed(context, Routes.editSecret, arguments: {'seed': widget.seed});
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result)));
    }
  }

  void _viewItem(BuildContext context, SecretItem secret) async {
    final result =
        await Navigator.pushNamed(context, Routes.viewSecret, arguments: {'seed': widget.seed, 'secretItem': secret});

    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result)));
    }
  }
}
