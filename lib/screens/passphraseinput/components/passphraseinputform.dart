import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PassphraseInputForm extends StatefulWidget {
  PassphraseInputForm({Key key, this.onSave, this.enabled = true}) : super(key: key);

  final ValueChanged<String> onSave;
  final bool enabled;

  @override
  State createState() => _PassphraseInputState();
}

class _PassphraseInputState extends State<PassphraseInputForm> {
  final _formKey = GlobalKey<FormState>();
  String _passphrase;
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: TextFormField(
              enabled: widget.enabled,
              decoration: InputDecoration(
                labelText: 'Passphrase',
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {
                    setState(() {
                      _obscured = !_obscured;
                    });
                  },
                ),
              ),
              autofocus: true,
              maxLines: null, // set to null to allow multiple lines
              obscureText: _obscured,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (value) => setState(() => _passphrase = value),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: RaisedButton(
              onPressed: widget.enabled ? _save : null,
              child: Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      widget.onSave(_passphrase);
    }
  }
}
