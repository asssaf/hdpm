import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/models/screenresult.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/derivedsecretitemfieldcustomizerform.dart';

class DerivedSecretItemFieldCustomizerScreen extends StatefulWidget {
  DerivedSecretItemFieldCustomizerScreen(
      {Key key, @required this.seed, @required this.secretItem, @required this.field})
      : assert(seed != null),
        super(key: key);

  final BIP32 seed;
  final SecretItem secretItem;
  final DerivedSecretItemField field;

  @override
  State createState() => _DerivedSecretITemFieldCustomizerState();
}

class _DerivedSecretITemFieldCustomizerState extends State<DerivedSecretItemFieldCustomizerScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();

  DerivedSecretItemField _field;

  @override
  void initState() {
    super.initState();
    _field = widget.field.rebuild(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: DerivedSecretItemFieldCustomizerForm(
        formKey: _formKey,
        seed: widget.seed,
        secretItem: widget.secretItem,
        field: widget.field,
        onChanged: (field) => setState(() => _field = field),
      ),
    );
  }

  void _save() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      Navigator.pop(context, ScreenResult(result: _field));
    }
  }
}
