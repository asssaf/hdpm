import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/derivedsecretitemfieldypeeditor.dart';
import 'package:hdpm/screens/derivedsecretitemfieldcustomizer/components/labeledintadjuster.dart';
import 'package:hdpm/services/computeutils.dart';
import 'package:rxdart/rxdart.dart';

class DerivedSecretItemFieldCustomizerForm extends StatefulWidget {
  DerivedSecretItemFieldCustomizerForm({
    Key key,
    this.formKey,
    @required this.seed,
    @required this.secretItem,
    @required this.field,
    this.onChanged,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final BIP32 seed;
  final SecretItem secretItem;
  final DerivedSecretItemField field;
  final ValueChanged<DerivedSecretItemField> onChanged;

  @override
  State createState() => _DerivedSecretItemFieldCustomizerFormState();
}

class _DerivedSecretItemFieldCustomizerFormState extends State<DerivedSecretItemFieldCustomizerForm> {
  int _slot;
  int _generation;

  Subject<int> _slotSubject;
  Subject<int> _generationSubject;
  Subject<DerivedSecretItemFieldType> _fieldTypeSubject;

  Observable<Uint8List> _secretObservable;

  @override
  void initState() {
    super.initState();

    _slotSubject = BehaviorSubject.seeded(widget.field.slot);
    _generationSubject = BehaviorSubject.seeded(widget.field.generation);
    _fieldTypeSubject = BehaviorSubject.seeded(widget.field.type);

    _slot = widget.field.slot;
    _generation = widget.field.generation;

    final fieldChangeObservable = Observable.combineLatest3(
            _slotSubject.stream,
            _generationSubject.stream,
            _fieldTypeSubject,
            (slot, generation, type) => widget.field.rebuild((b) => b
              ..slot = slot
              ..generation = generation
              ..type = type))
        .doOnData(widget.onChanged)
        .distinct((prev, next) => prev.slot == next.slot && prev.generation == next.generation)
        .asBroadcastStream();

    _secretObservable = computeAndDropOldResultsInvalidate(
        fieldChangeObservable, (field) => field.deriveSecret(widget.seed, widget.secretItem.path));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Column(
              children: <Widget>[
                LabeledIntAdjuster(
                  label: 'Slot',
                  value: _slot,
                  min: 1,
                  max: 10000,
                  onChanged: _fieldSlotChanged,
                ),
                LabeledIntAdjuster(
                  label: 'Generation',
                  value: _generation,
                  min: 1,
                  max: 10000,
                  onChanged: _fieldGenerationChanged,
                ),
                StreamBuilder(
                  stream: _secretObservable,
                  builder: (context, snapshot) => DerivedSecretItemFieldTypeEditor(
                        secret: snapshot.data,
                        initialValue: widget.field.type,
                        onChanged: _fieldTypeChanged,
                      ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _fieldTypeChanged(DerivedSecretItemFieldType fieldType) {
    _fieldTypeSubject.add(fieldType);
  }

  void _fieldSlotChanged(int newSlot) {
    _slotSubject.add(newSlot);
    setState(() => _slot = newSlot);
  }

  void _fieldGenerationChanged(int newGeneration) {
    _generationSubject.add(newGeneration);
    setState(() => _generation = newGeneration);
  }
}
