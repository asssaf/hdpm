import 'dart:convert';
import 'dart:io';

import 'package:bip32/bip32.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/models/secretitem/serializers.dart';
import 'package:hdpm/services/inmemsecretrepository.dart';
import 'package:hdpm/services/secretderiver.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import 'encryption.dart';

class SingleFileSecretRepository extends InMemSecretRepository {
  SingleFileSecretRepository({@required this.path, @required this.seed})
      : assert(path != null),
        assert(seed != null);

  final String path;
  final BIP32 seed;

  final standardSerializers = (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

  @override
  Future<void> open() async {
    await _importFromStore();
  }

  @override
  Future<bool> save(SecretItem secret) async {
    final result = await super.save(secret);

    await _exportToStore();

    return result;
  }

  @override
  Future<bool> delete(SecretItem secret) async {
    final result = await super.delete(secret);

    await _exportToStore();

    return result;
  }

  Future<File> _getFile() {
    return getApplicationDocumentsDirectory().then((dir) => File('${dir.path}/$path'));
  }

  Future<void> _importFromStore() async {
    final file = await _getFile();
    final exists = await file.exists();
    if (!exists) {
      import([]);
    } else {
      final data = await file.readAsBytes();

      final hmacKey = await SecretDeriver().deriveSecret(seed, "m/2'/1'");
      final key = await SecretDeriver().deriveSecret(seed, "m/2'/2'");
      final decrypted = decrypt(hmacKey, key, data);

      final contents = utf8.decode(decrypted);

      final List<dynamic> items = json.decode(contents);
      final List<SecretItem> secretItems = items.map(standardSerializers.deserialize).cast<SecretItem>().toList();

      import(secretItems);
    }
  }

  Future<void> _exportToStore() async {
    final secrets = export() ?? [];
    final file = await _getFile();

    final items = secrets.map(standardSerializers.serialize).toList();
    final contents = json.encode(items);

    final hmacKey = await SecretDeriver().deriveSecret(seed, "m/2'/1'");
    final key = await SecretDeriver().deriveSecret(seed, "m/2'/2'");
    final data = encrypt(null, hmacKey, key, utf8.encode(contents));

    await file.writeAsBytes(data, flush: true);
  }

  Future<void> _deleteStore() async {
    final file = await _getFile();
    await file.delete();
  }
}
