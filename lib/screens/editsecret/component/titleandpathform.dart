import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/services/computeutils.dart';
import 'package:hdpm/services/derivationpathdgenerator.dart';
import 'package:rxdart/rxdart.dart';

class TitleAndPathForm extends StatefulWidget {
  TitleAndPathForm({Key key, this.formKey, this.secretItem, this.secretItemBuilder}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final SecretItem secretItem;
  final SecretItemBuilder secretItemBuilder;

  @override
  State createState() => _TitleAndPathFormState();
}

class _TitleAndPathFormState extends State<TitleAndPathForm> {
  TextEditingController _titleController;
  BehaviorSubject<String> _titleSubject;
  bool _hasManualPath;
  Observable<String> _autoPathObservable;
  DerivationPathGenerator _derivationPathGenerator = DerivationPathGenerator();

  @override
  void initState() {
    super.initState();

    _titleSubject = BehaviorSubject.seeded('');
    _titleController = TextEditingController(text: widget.secretItem.title);
    _titleController.addListener(() => _titleSubject.add(_titleController.text));

    _hasManualPath = widget.secretItem.hasManualPath;
    _autoPathObservable =
        computeAndDropOldResultsInvalidate<String, String>(_titleSubject.stream, _derivationPathGenerator.textToPath);

    widget.secretItemBuilder.replace(widget.secretItem);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          ListTile(
            title: TextFormField(
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              controller: _titleController,
              autofocus: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (value) => widget.secretItemBuilder.title = value,
            ),
          ),
          SwitchListTile(
            title: Text('Autogenerate derivation path'),
            value: !_hasManualPath, //!_secretItem.hasManualPath,
            onChanged: (value) => setState(() {
              _hasManualPath = !value;
              widget.secretItemBuilder.hasManualPath = !value;
            }),
          ),
          Offstage(
            offstage: _hasManualPath,
            child: _buildAutoDerivationPath(),
          ),
          Offstage(
            offstage: !_hasManualPath,
            child: _buildManualDerivationPath(),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoDerivationPath() {
    return StreamBuilder(
      stream: _autoPathObservable,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return ListTile(
          title: Text('Derivation Path'),
          subtitle: snapshot.hasData ? Text(snapshot.data) : Text('Calculating...'),
        );
      },
    );
  }

  Widget _buildManualDerivationPath() {
    return ListTile(
      title: TextFormField(
        decoration: InputDecoration(
          labelText: 'Derivation Path',
          hintText: "m/0'/0/1",
        ),
        autofocus: true,
        validator: (value) {
          if (widget.secretItem.hasManualPath) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            //TODO validate bip32 path
          }
          return null;
        },
        onSaved: (value) {
          if (widget.secretItem.hasManualPath) {
            widget.secretItemBuilder.path = value;
          }
        },
      ),
    );
  }
}
