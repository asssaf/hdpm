import 'dart:async';
import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem.dart';
import 'package:hdpm/screens/editsecret/component/mnemonicsecret.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final Logger _logger = Logger('EditSecretForm');

class EditSecretForm extends StatefulWidget {
  EditSecretForm({Key key, @required this.seed, @required this.secretItem})
      : assert(seed != null),
        assert(secretItem != null),
        super(key: key);

  final BIP32 seed;
  final SecretItem secretItem;

  @override
  State createState() => _EditSecretFormState();
}

class _EditSecretFormState extends State<EditSecretForm> {
  GlobalKey<FormState> _formKey = GlobalKey();
  Observable<String> _pathObservable;
  Observable<Uint8List> _secretObservable;

  static const _secretTypes = ["Mnemonic Passphrase"];
  String _secretType = _secretTypes[0];
  int _wordCount = 12;

  @override
  void initState() {
    super.initState();

    _pathObservable = Observable.just(widget.secretItem.path).asBroadcastStream();
    _secretObservable = _pathObservable.asyncMap(_deriveSecretFromPath).asBroadcastStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Uint8List> _deriveSecretFromPath(String path) async {
    _logger.finest('Starting secret derivation');
    final node = await compute(_derivePath, _PathDerivationInput(widget.seed, path));
    final secret = Uint8List.fromList(node.privateKey.sublist(0, 16));
    _logger.finest('Finished secret derivation');
    return secret;
  }

  static BIP32 _derivePath(_PathDerivationInput input) {
    final node = input.seed.derivePath(input.path);

    return node;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          ListTile(
            title: TextFormField(
              decoration: InputDecoration(
                labelText: 'Site',
              ),
              autofocus: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              },
            ),
          ),
          ListTile(
            title: TextFormField(
              decoration: InputDecoration(
                labelText: 'Username',
              ),
              autofocus: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              },
            ),
          ),
          ListTile(
            leading: Text('Type'),
            title: DropdownButton<String>(
              value: _secretType,
              items: _secretTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _secretType = value),
            ),
          ),
          MnemonicSecret(
            secretStream: _secretObservable,
            wordCount: _wordCount,
            onWordCountChanged: (value) => setState(() => _wordCount = value),
          ),
        ],
      ),
    );
  }
}

// input for the _derivePath compute function
class _PathDerivationInput {
  _PathDerivationInput(this.seed, this.path);

  final BIP32 seed;
  final String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PathDerivationInput && runtimeType == other.runtimeType && seed == other.seed && path == other.path;

  @override
  int get hashCode => seed.hashCode ^ path.hashCode;
}
