import 'dart:async';

import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/components/app/appbarbuilder.dart';
import 'package:hdpm/models/screenresult.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/screens/editsecret/component/editsecretform.dart';
import 'package:hdpm/screens/editsecret/component/titleandpathform.dart';
import 'package:hdpm/services/derivationpathdenerator.dart';
import 'package:hdpm/services/secretrepository.dart';

import '../../appstatecontainer.dart';

class EditSecretScreen extends StatefulWidget {
  EditSecretScreen({
    Key key,
    this.title,
    @required this.seed,
    this.secretItem,
  })  : assert(seed != null),
        super(key: key);

  final String title;
  final SecretItem secretItem;
  final BIP32 seed;

  @override
  State createState() => _EditSecretState();
}

class _EditSecretState extends State<EditSecretScreen> {
  GlobalKey<FormState> _titleFormKey = GlobalKey();
  GlobalKey<FormState> _secretFormKey = GlobalKey();
  DerivationPathGenerator _derivationPathGenerator = DerivationPathGenerator();

  SecretItemBuilder _secretItemBuilder = SecretItemBuilder();

  @override
  void initState() {
    super.initState();
    _secretItemBuilder.replace(widget.secretItem);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.secretItem.path == null) {
      return Scaffold(
        appBar: AppBarBuilder().build(
          context: context,
          title: widget.title,
          locked: true,
        ),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: TitleAndPathForm(
                formKey: _titleFormKey,
                secretItem: widget.secretItem,
                secretItemBuilder: _secretItemBuilder,
              ),
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () => _saveTitleForm(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSecret,
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: EditSecretForm(
          formKey: _secretFormKey,
          seed: widget.seed,
          secretItem: _secretItemBuilder.build(),
          secretItemBuilder: _secretItemBuilder,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unsaved Edit'),
          content: Text('Unsaved entry will be lost. Continue?'),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );

    return confirmed == true;
  }

  void _saveTitleForm() async {
    final form = _titleFormKey.currentState;
    if (form.validate()) {
      form.save();

      if (!_secretItemBuilder.hasManualPath) {
        _secretItemBuilder.path = await _derivationPathGenerator.textToPath(_secretItemBuilder.title);
      }

      final secretItem = _secretItemBuilder.build();

      Completer<dynamic> completer = Completer();
      final result = Navigator.pushReplacementNamed(context, Routes.editSecret,
          result: completer.future, arguments: {'seed': widget.seed, 'secretItem': secretItem});

      completer.complete(result);
    }
  }

  void _saveSecret() async {
    final form = _secretFormKey.currentState;
    if (form.validate()) {
      form.save();

      SecretRepository _secretRepository = AppStateContainer.of(context).state.secretRepository;

      final secretItem = _secretItemBuilder.build();
      await _secretRepository.save(secretItem);

      Navigator.pop(context, ScreenResult(message: 'Saved', result: secretItem));
    }
  }
}
