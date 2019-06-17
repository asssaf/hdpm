import 'dart:async';
import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/screens/editsecret/component/mnemonicsecret.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:rxdart/rxdart.dart';

final Logger _logger = Logger('EditSecretForm');

class EditSecretForm extends StatefulWidget {
  EditSecretForm({Key key, @required this.seed})
      : assert(seed != null),
        super(key: key);

  final BIP32 seed;

  @override
  State createState() => _EditSecretFormState();
}

class _EditSecretFormState extends State<EditSecretForm> {
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _siteController;
  TextEditingController _usernameController;

  BehaviorSubject<String> _siteSubject;
  BehaviorSubject<String> _usernameSubject;

  Observable<_PathProvider> _pathObservable;
  Observable<Uint8List> _secretObservable;

  static const _secretTypes = ["Mnemonic Passphrase"];
  String _secretType = _secretTypes[0];
  int _wordCount = 12;

  @override
  void initState() {
    super.initState();

    _siteSubject = BehaviorSubject.seeded('');
    _siteController = TextEditingController();
    _siteController.addListener(() => _siteSubject.add(_siteController.text));

    _usernameSubject = BehaviorSubject.seeded('');
    _usernameController = TextEditingController();
    _usernameController.addListener(() => _usernameSubject.add(_usernameController.text));

    _pathObservable = Observable.combineLatest2(_siteSubject.distinct(), _usernameSubject.distinct(),
        (site, username) => _HashPathProvider("$site\x00$username\x00")).asBroadcastStream();

    _secretObservable = Observable.merge([
      // whenever the path changes, the previous value is invalidated until the new secret is computed
      _pathObservable.mapTo(null),
      // compute the new secret after debouncing
      _pathObservable.debounceTime(Duration(milliseconds: 500)).asyncMap(_deriveSecretFromPath).withLatestFrom(
          _pathObservable, (s, p) => s.source == p ? s.secret : null) // if this secret is out of date throw it out
    ]).asBroadcastStream();
  }

  @override
  void dispose() {
    _siteSubject.close();
    _siteController.dispose();
    _usernameSubject.close();
    _usernameController.dispose();

    super.dispose();
  }

  Future<_SecretWithSource> _deriveSecretFromPath(_PathProvider pathProvider) async {
    _logger.finest('Starting secret derivation');
    final node = await compute(_derivePath, _PathDerivationInput(widget.seed, pathProvider.path));
    final secret = Uint8List.fromList(node.privateKey.sublist(0, 16));
    _logger.finest('Finished secret derivation');
    return _SecretWithSource(pathProvider, secret);
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
              controller: _siteController,
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
              controller: _usernameController,
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

abstract class _PathProvider {
  String get path;
}

class _HashPathProvider extends _PathProvider {
  _HashPathProvider(this.id);

  final String id;

  @override
  String get path {
    final digest = RIPEMD160Digest().process(Uint8List.fromList(id.codeUnits));

    var path = "m/1";
    for (int i = 0; i < 6; ++i) {
      int index = 0;
      for (int j = 0; j < 3; ++j) {
        index = index << 8;
        index += digest[i * 3 + j];
      }
      path += "/$index";
    }

    return path;
  }
}

class _SecretWithSource {
  _SecretWithSource(this.source, this.secret);

  final _PathProvider source;
  final Uint8List secret;
}
