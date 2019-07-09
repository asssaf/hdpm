import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';

void main() {
  test('SecretItem fields get cloned', () {
    final fields = [
      CustomSecretItemField((b) => b
        ..name = 'name1'
        ..value = 'value1'),
    ];

    final secretItem = SecretItem((b) {
      b.title = "test";
      b.fields = ListBuilder<SecretItemField>(fields);
    });

    final secretItemCopy = secretItem.rebuild(null);

    expect(secretItemCopy.fields.length, 1);

    expect(secretItemCopy.fields[0], isInstanceOf<CustomSecretItemField>());
    final CustomSecretItemField field1 = secretItemCopy.fields[0];
    expect(field1.name, fields[0].name);
    expect(field1.value, fields[0].value);
  });

  test('Deriving path directly or in two segments results in same value', () {
    BIP32 seed = BIP32.fromSeed(Uint8List.fromList(List.filled(32, 0)));

    final pathSegment1 = "1/2";
    final pathSegment2 = 3;

    final fullPath = 'm/$pathSegment1/$pathSegment2';
    final derivedFull = seed.derivePath(fullPath);

    final derivedSegment1 = seed.derivePath('m/$pathSegment1');
    final derivedBoth = derivedSegment1.derive(pathSegment2);
    expect(derivedFull.privateKey, derivedBoth.privateKey);
  });
}
