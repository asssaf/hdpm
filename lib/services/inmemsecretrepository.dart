import 'package:hdpm/models/secretitem/secretitem.dart';
import 'package:hdpm/services/secretrepository.dart';
import 'package:rxdart/rxdart.dart';

class InMemSecretRepository extends SecretRepository {
  InMemSecretRepository() {
    _secretsSubject.add(_secrets);
  }

  final List<SecretItem> _secrets = List();
  final BehaviorSubject<List<SecretItem>> _secretsSubject = BehaviorSubject();

  @override
  Observable<List<SecretItem>> findAll() {
    return _secretsSubject.stream;
  }

  @override
  Observable<SecretItem> findByPath(String path) {
    return _secretsSubject.stream
        .map((secrets) => secrets.firstWhere((secret) => secret.path == path, orElse: () => null));
  }

  @override
  Observable<SecretItem> findByTitle(String title) {
    return _secretsSubject.stream
        .map((secrets) => secrets.firstWhere((secret) => secret.title == title, orElse: () => null));
  }

  @override
  Future<bool> save(SecretItem secret) async {
    final index = _secrets.indexWhere((s) => s.path == secret.path);
    if (index >= 0) {
      _secrets[index] = secret;
    } else {
      _secrets.add(secret);
    }

    _secrets.sort((a, b) => a.title.compareTo(b.title));
    _secretsSubject.add(new List.from(_secrets));

    return true;
  }

  @override
  Future<bool> delete(SecretItem secret) async {
    final result = _secrets.remove(secret);
    if (result) {
      _secretsSubject.add(_secrets);
    }
    return result;
  }

  void import(List<SecretItem> secrets) {
    _secrets.clear();
    _secrets.addAll(secrets);
    _secretsSubject.add(_secrets);
  }

  List<SecretItem> export() {
    return List.from(_secrets);
  }
}
