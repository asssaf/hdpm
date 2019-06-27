import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem.dart';
import 'package:hdpm/services/derivationpathdenerator.dart';
import 'package:rxdart/rxdart.dart';

class TitleAndPathForm extends StatefulWidget {
  TitleAndPathForm({Key key, this.formKey, this.secretItem}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final SecretItem secretItem;

  @override
  State createState() => _TitleAndPathFormState();
}

class _TitleAndPathFormState extends State<TitleAndPathForm> {
  TextEditingController _titleController;
  BehaviorSubject<String> _titleSubject;
  Observable<String> _autoPathObservable;
  DerivationPathGenerator _derivationPathGenerator = DerivationPathGenerator();

  @override
  void initState() {
    super.initState();

    _titleSubject = BehaviorSubject.seeded('');
    _titleController = TextEditingController(text: widget.secretItem.title);
    _titleController.addListener(() => _titleSubject.add(_titleController.text));

    _autoPathObservable = Observable.merge([
      // invalidate previous result as soon as a new computation is started
      _titleSubject.mapTo(null),
      _computeAndDropOldResults<String, String>(_titleSubject, _derivationPathGenerator.textToPath),
    ]);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SecretItem _secretItem = widget.secretItem;

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
              },
              onSaved: (value) => setState(() => _secretItem.title = value),
            ),
          ),
          SwitchListTile(
            title: Text('Autogenerate derivation path'),
            value: !_secretItem.hasManualPath,
            onChanged: (value) => setState(() => _secretItem.hasManualPath = !value),
          ),
          Offstage(
            offstage: _secretItem.hasManualPath,
            child: _buildAutoDerivationPath(),
          ),
          Offstage(
            offstage: !_secretItem.hasManualPath,
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
        },
        onSaved: (value) {
          if (widget.secretItem.hasManualPath) {
            widget.secretItem.path = value;
          }
        },
      ),
    );
  }

  static Observable<T> _computeAndDropOldResults<S, T>(Observable<S> source, Future<T> fn(S s)) {
    return source
        .distinct()
        .debounceTime(Duration(milliseconds: 250))
        .asyncMap(fn)
        .switchMap((t) => Observable.just(t));
  }
}
