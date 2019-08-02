import 'dart:typed_data';

import 'package:bs58check/bs58check.dart' show base58;
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';

part 'passwordsecretitemfieldtype.g.dart';

abstract class PasswordSecretItemFieldType
    implements DerivedSecretItemFieldType, Built<PasswordSecretItemFieldType, PasswordSecretItemFieldTypeBuilder> {
  PasswordSecretItemFieldType._();
  factory PasswordSecretItemFieldType() = _$PasswordSecretItemFieldType;

  static Serializer<PasswordSecretItemFieldType> get serializer => _$passwordSecretItemFieldTypeSerializer;

  int get length;

  @override
  String get name => 'Password';

  @override
  Future<String> deriveValue(Uint8List secret) async {
    return base58.encode(secret);
  }

  @override
  String deriveFinalValue(String value) {
    return value.substring(0, length);
  }

  @override
  PasswordSecretItemFieldType clone() => this.rebuild(null);
}

abstract class PasswordSecretItemFieldTypeBuilder
    implements Builder<PasswordSecretItemFieldType, PasswordSecretItemFieldTypeBuilder> {
  PasswordSecretItemFieldTypeBuilder._();
  factory PasswordSecretItemFieldTypeBuilder() = _$PasswordSecretItemFieldTypeBuilder;

  int length = 12;
}
