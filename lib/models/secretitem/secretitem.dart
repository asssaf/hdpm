import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hdpm/models/secretitem/mnemonicpassphrasesecretitemfieldtype.dart';

part 'secretitem.g.dart';

abstract class SecretItem implements Built<SecretItem, SecretItemBuilder> {
  SecretItem._();
  factory SecretItem([void Function(SecretItemBuilder) updates]) = _$SecretItem;

  @nullable
  String get title;

  bool get hasManualPath;

  @nullable
  String get path;

  BuiltList<SecretItemField> get fields;

  @override
  String toString() {
    return 'SecretItem{title: $title, hasManualPath: $hasManualPath, path: $path}';
  }
}

abstract class SecretItemBuilder implements Builder<SecretItem, SecretItemBuilder> {
  String title;
  bool hasManualPath = false;
  String path;
  ListBuilder<SecretItemField> fields = ListBuilder<SecretItemField>(_defaultFields());

  SecretItemBuilder._();
  factory SecretItemBuilder() = _$SecretItemBuilder;

  static List<SecretItemField> _defaultFields() {
    return [
      CustomSecretItemField((b) => b.name = 'Site'),
      CustomSecretItemField((b) => b.name = 'Username'),
      DerivedSecretItemField((b) => b
        ..name = 'Password'
        ..type = MnemonicPassphraseSecretItemFieldType()),
    ];
  }
}

abstract class SecretItemField {
  String get name;
}

abstract class CustomSecretItemField
    implements SecretItemField, Built<CustomSecretItemField, CustomSecretItemFieldBuilder> {
  CustomSecretItemField._();
  factory CustomSecretItemField([void Function(CustomSecretItemFieldBuilder) updates]) = _$CustomSecretItemField;

  @nullable
  String get value;

  static const Type gtype = _$CustomSecretItemField;
}

abstract class DerivedSecretItemField
    implements SecretItemField, Built<DerivedSecretItemField, DerivedSecretItemFieldBuilder> {
  DerivedSecretItemField._();
  factory DerivedSecretItemField([void Function(DerivedSecretItemFieldBuilder) updates]) = _$DerivedSecretItemField;

  int get slot;
  int get generation;
  DerivedSecretItemFieldType get type;

  Future<Uint8List> deriveSecret(BIP32 seed, String basePath) async {
    final fullPath = "$basePath/$slot'/$generation'";
    final input = _PathDerivationInput(seed, fullPath);
    final node = await compute(_derivePath, input);

    // append the path to the private key (in case an index is skipped by derivation)
    final prehash = node.privateKey + fullPath.codeUnits;

    final hashed = sha256.newInstance().convert(prehash).bytes;
    return hashed;
  }

  Future<String> deriveValue(Uint8List secret) => type.deriveValue(secret);
  String deriveFinalValue(String value) => type.deriveFinalValue(value);

  static BIP32 _derivePath(_PathDerivationInput input) {
    final node = input.seed.derivePath(input.path);

    return node;
  }

  static const Type gtype = _$DerivedSecretItemField;
}

abstract class DerivedSecretItemFieldBuilder implements Builder<DerivedSecretItemField, DerivedSecretItemFieldBuilder> {
  DerivedSecretItemFieldBuilder._();
  factory DerivedSecretItemFieldBuilder() = _$DerivedSecretItemFieldBuilder;

  String name;
  int slot = 1;
  int generation = 1;
  DerivedSecretItemFieldType type = MnemonicPassphraseSecretItemFieldType();
}

abstract class DerivedSecretItemFieldType {
  Future<String> deriveValue(Uint8List secret);
  String deriveFinalValue(String value);
  DerivedSecretItemFieldType clone();
  String get name;
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
