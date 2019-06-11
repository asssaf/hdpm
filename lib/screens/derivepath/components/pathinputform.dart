import 'package:flutter/material.dart';

class PathInputForm extends StatefulWidget {
  PathInputForm({Key key, this.title, this.onSave}) : super(key: key);

  final String title;
  final ValueChanged<String> onSave;

  @override
  _PathInputFormState createState() => _PathInputFormState();
}

class _PathInputFormState extends State<PathInputForm> {
  final _formKey = GlobalKey<FormState>();
  String _path;

  void save() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      widget.onSave(_path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Derivation Path',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              //TODO validate bip32 path
            },
            onSaved: (value) => setState(() => _path = value),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: RaisedButton(
              onPressed: () {
                save();
              },
              child: Text('Derive'),
            ),
          ),
        ],
      ),
    );
  }
}
