import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hex/hex.dart';

part 'mnemonicpassphrasesecretitemfieldtype.g.dart';

abstract class MnemonicPassphraseSecretItemFieldType
    implements
        DerivedSecretItemFieldType,
        Built<MnemonicPassphraseSecretItemFieldType, MnemonicPassphraseSecretItemFieldTypeBuilder> {
  MnemonicPassphraseSecretItemFieldType._();
  factory MnemonicPassphraseSecretItemFieldType() = _$MnemonicPassphraseSecretItemFieldType;

  static Serializer<MnemonicPassphraseSecretItemFieldType> get serializer =>
      _$mnemonicPassphraseSecretItemFieldTypeSerializer;

  int get wordCount;

  @override
  String get name => 'Mnemonic Passphrase';

  @override
  Future<String> deriveValue(Uint8List secret) async {
    final String ent = HEX.encode(secret.sublist(0, 16));
    final mnemonic = bip39.entropyToMnemonic(ent);
    return mnemonic;
  }

  @override
  String deriveFinalValue(String value) {
    final words = value.split(' ').sublist(0, wordCount).join(' ');

    return words;
  }

  @override
  MnemonicPassphraseSecretItemFieldType clone() => this.rebuild(null);
}

abstract class MnemonicPassphraseSecretItemFieldTypeBuilder
    implements Builder<MnemonicPassphraseSecretItemFieldType, MnemonicPassphraseSecretItemFieldTypeBuilder> {
  MnemonicPassphraseSecretItemFieldTypeBuilder._();

  factory MnemonicPassphraseSecretItemFieldTypeBuilder() = _$MnemonicPassphraseSecretItemFieldTypeBuilder;

  int wordCount = 12;
}
