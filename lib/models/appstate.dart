import 'package:hdpm/services/inmemsecretrepository.dart';
import 'package:hdpm/services/secretrepository.dart';

class AppState {
  final SecretRepository secretRepository = InMemSecretRepository();
}
