import 'dart:async';

import 'package:hdpm/models/secretitem.dart';
import 'package:rxdart/rxdart.dart';

class SecretRepository {
  SecretRepository() {
    _secretsSubject.add(_secrets);
  }

  final List<SecretItem> _secrets = List();
  final BehaviorSubject<List<SecretItem>> _secretsSubject = BehaviorSubject();

  Observable<List<SecretItem>> findAll() {
    return _secretsSubject.stream;
  }

  Future<bool> save(SecretItem secret) async {
    _secrets.add(secret);
    _secretsSubject.add(new List.from(_secrets));
    return true;
  }
}
