import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SeedInputForm extends StatefulWidget {
  SeedInputForm({Key key, this.title, this.onSave}) : super(key: key);

  final String title;
  final ValueChanged<Uint8List> onSave;

  @override
  _SeedInputFormState createState() => _SeedInputFormState();
}

class _SeedInputFormState extends State<SeedInputForm> {
  final _formKey = GlobalKey<FormState>();
  String _mnemonic;
  bool _processing = false;
  TextEditingController _mnemonicController;

  @override
  void initState() {
    super.initState();
    _mnemonicController = new TextEditingController();
  }

  @override
  void dispose() {
    _mnemonicController.dispose();
    super.dispose();
  }

  void _generate() {
    String generated = bip39.generateMnemonic();
    _mnemonicController.text = generated;
  }

  void _save() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _processing = true;
      });

      //TODO warn if seed isn't valid but allow proceeding anyway
      //print('mnemonic valid: ${bip39.validateMnemonic(_mnemonic)}');
      final seed = await compute(bip39.mnemonicToSeed, _mnemonic);

      widget.onSave(seed);

      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: TextFormField(
              enabled: !_processing,
              controller: _mnemonicController,
              decoration: InputDecoration(
                labelText: 'Seed',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _mnemonicController.clear());
                  },
                ),
              ),
              autofocus: true,
              maxLines: null,
              // set to null to allow multiple lines
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (value) => setState(() => _mnemonic = value),
            ),
          ),
          ButtonBar(
            children: <Widget>[
              RaisedButton(
                onPressed: _processing ? null : _generate,
                child: Text('Generate'),
              ),
              RaisedButton(
                onPressed: _processing ? null : _save,
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
