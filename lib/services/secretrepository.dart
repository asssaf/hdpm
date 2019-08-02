import 'dart:async';

import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:rxdart/rxdart.dart';

abstract class SecretRepository {
  Observable<List<SecretItem>> findAll();
  Observable<SecretItem> findByPath(String path);
  Future<bool> save(SecretItem secret);
  Future<bool> delete(SecretItem secret);
}
