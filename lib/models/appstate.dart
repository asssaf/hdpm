import 'package:bip32/bip32.dart';
import 'package:hdpm/services/secretrepository.dart';
import 'package:hdpm/services/singlefilesecretrepository.dart';

class AppState {
  SecretRepository secretRepository;

  Future<void> openSecretStore({String path = 'store.dat', BIP32 seed}) async {
    if (secretRepository != null) {
      secretRepository.close();
    }

    secretRepository = SingleFileSecretRepository(path: path, seed: seed);
    return await secretRepository.open();
  }
}
