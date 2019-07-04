import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem.dart';
import 'package:hdpm/screens/editsecret/component/mnemonicpassphrasesecreteditor.dart';

class DerivedSecretItemFieldFormField extends FormField<MnemonicPassphraseSecretItemField> {
  DerivedSecretItemFieldFormField(
      {FormFieldSetter<MnemonicPassphraseSecretItemField> onSaved,
      FormFieldValidator<MnemonicPassphraseSecretItemField> validator,
      MnemonicPassphraseSecretItemField initialValue,
      bool autovalidate = false,
      @required String mnemonic})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidate: autovalidate,
            builder: (FormFieldState<MnemonicPassphraseSecretItemField> state) {
              final value = state.value;

              return MnemonicPassphraseSecretEditor(
                title: value.name,
                mnemonic: value.deriveFinalValue(mnemonic),
                wordCount: value.wordCount,
                onWordCountChanged: (wordCount) =>
                    state.didChange(MnemonicPassphraseSecretItemField.copy(value, wordCount: wordCount)),
              );
            });
}
