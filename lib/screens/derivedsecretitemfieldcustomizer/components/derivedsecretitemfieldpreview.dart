import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/models/screenresult.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/routes.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/derivedsecretitemfieldtypepreview.dart';

class DerivedSecretItemFieldPreview extends StatefulWidget {
  DerivedSecretItemFieldPreview({Key key, this.seed, this.secretItem, this.field, this.onChanged}) : super(key: key);

  final BIP32 seed;
  final SecretItem secretItem;
  final DerivedSecretItemField field;
  final ValueChanged<SecretItemField> onChanged;

  @override
  State createState() => _DerivedSecretItemFieldPreviewState();
}

class _DerivedSecretItemFieldPreviewState extends State<DerivedSecretItemFieldPreview> {
  Future<Uint8List> _secret;
  Future<String> _secretValue;

  @override
  void initState() {
    super.initState();
    _updateSecret();
  }

  @override
  void didUpdateWidget(DerivedSecretItemFieldPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seed != widget.seed ||
        oldWidget.field.slot != widget.field.slot ||
        oldWidget.field.generation != widget.field.generation) {
      _updateSecret();
    } else if (oldWidget.field.type != widget.field.type) {
      _updateSecretValue();
    }
  }

  void _updateSecret() {
    _secret = widget.field.deriveSecret(widget.seed, widget.secretItem.path);
    _updateSecretValue();
  }

  void _updateSecretValue() {
    _secretValue = _secret?.then(widget.field.deriveValue) ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return DerivedSecretItemFieldTypePreview(
      title: widget.field.name,
      fieldType: widget.field.type,
      secretValue: _secretValue,
      onCustomize: widget.onChanged != null ? (_) => _customize() : null,
    );
  }

  void _customize() async {
    final result = await Navigator.pushNamed(context, Routes.customizeDerivedField, arguments: {
      'seed': widget.seed,
      'secretItem': widget.secretItem,
      'field': widget.field,
    });

    if (result is ScreenResult<DerivedSecretItemField>) {
      widget.onChanged(result.result);
    }
  }
}
