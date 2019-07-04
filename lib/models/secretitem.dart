import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';

class SecretItem {
  SecretItem() {
    fields = _defaultFields(this);
  }

  String title;
  bool hasManualPath = false;
  String path;

  List<SecretItemField> fields;

  @override
  String toString() {
    return 'SecretItem{title: $title, hasManualPath: $hasManualPath, path: $path}';
  }

  static List<SecretItemField> _defaultFields(SecretItem secretItem) {
    return [
      CustomSecretItemField(secretItem: secretItem)..name = 'Site',
      CustomSecretItemField(secretItem: secretItem)..name = 'Username',
      MnemonicPassphraseSecretItemField(secretItem: secretItem)..name = 'Password',
    ];
  }
}

abstract class SecretItemField {
  SecretItemField({SecretItem secretItem, this.name}) : _secretItem = secretItem;
  SecretItemField.copy(SecretItemField toCopy, {String name})
      : this(secretItem: toCopy._secretItem, name: name ?? toCopy.name);

  final SecretItem _secretItem;
  String name;
}

class CustomSecretItemField extends SecretItemField {
  CustomSecretItemField({SecretItem secretItem, this.value}) : super(secretItem: secretItem);
  CustomSecretItemField.copy(CustomSecretItemField toCopy, {String value})
      : value = value ?? toCopy.value,
        super.copy(toCopy);

  String value;
}

abstract class DerivedSecretItemField extends SecretItemField {
  DerivedSecretItemField({SecretItem secretItem, this.index = 1, this.generation = 1}) : super(secretItem: secretItem);
  DerivedSecretItemField.copy(DerivedSecretItemField toCopy, {int index, int generation})
      : index = index ?? toCopy.index,
        generation = generation ?? toCopy.generation,
        super.copy(toCopy);

  int index;
  int generation;

  Future<Uint8List> deriveSecret(BIP32 seed) async {
    final input = _PathDerivationInput(seed, "${_secretItem.path}/$index'/$generation'");
    final node = await compute(_derivePath, input);
    final secret = Uint8List.fromList(node.privateKey.sublist(0, 16));
    return secret;
  }

  Future<String> deriveValue(Uint8List secret);
  String deriveFinalValue(String value);

  static BIP32 _derivePath(_PathDerivationInput input) {
    final node = input.seed.derivePath(input.path);

    return node;
  }
}

class MnemonicPassphraseSecretItemField extends DerivedSecretItemField {
  MnemonicPassphraseSecretItemField({SecretItem secretItem, this.wordCount = 12}) : super(secretItem: secretItem);
  MnemonicPassphraseSecretItemField.copy(MnemonicPassphraseSecretItemField toCopy, {int wordCount})
      : wordCount = wordCount ?? toCopy.wordCount,
        super.copy(toCopy);

  int wordCount = 12;

  @override
  Future<String> deriveValue(Uint8List secret) async {
    final String ent = HEX.encode(secret);
    final mnemonic = bip39.entropyToMnemonic(ent);
    return mnemonic;
  }

  @override
  String deriveFinalValue(String value) {
    final words = value.split(' ').sublist(0, wordCount).join(' ');

    return words;
  }
}

// input for the _derivePath compute function
class _PathDerivationInput {
  _PathDerivationInput(this.seed, this.path);

  final BIP32 seed;
  final String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PathDerivationInput && runtimeType == other.runtimeType && seed == other.seed && path == other.path;

  @override
  int get hashCode => seed.hashCode ^ path.hashCode;
}
