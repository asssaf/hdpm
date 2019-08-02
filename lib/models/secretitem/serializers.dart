import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:hdpm/models/secretitem/mnemonicpassphrasesecretitemfieldtype.dart';
import 'package:hdpm/models/secretitem/passwordsecretitemfieldtype.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  SecretItem,
  CustomSecretItemField,
  DerivedSecretItemField,
  MnemonicPassphraseSecretItemFieldType,
  PasswordSecretItemFieldType,
  BuiltList,
])
final Serializers serializers = _$serializers;
