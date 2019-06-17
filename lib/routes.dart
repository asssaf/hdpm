import 'package:flutter/material.dart';
import 'package:hdpm/screens/derivepath/derivepathscreen.dart';
import 'package:hdpm/screens/editsecret/editsecretscreen.dart';
import 'package:hdpm/screens/passphraseinput/passphraseinputscreen.dart';
import 'package:hdpm/screens/seedinput/seedinputscreen.dart';

class Routes {
  static const initial = '/';
  static const seedInput = '/seedinput';
  static const derivePath = '/derivepath';
  static const editSecret = '/editSecret';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => PassphraseInputScreen(title: 'hdpm'));
      case seedInput:
        var key = settings.arguments;
        return MaterialPageRoute(builder: (_) => SeedInputScreen(title: 'Seed Input', seedEncryptionKey: key));
      case derivePath:
        var seed = settings.arguments;
        return MaterialPageRoute(builder: (_) => DerivePathScreen(title: 'Derive Path', seed: seed));
      case editSecret:
        var seed = settings.arguments;
        return MaterialPageRoute(builder: (_) => EditSecretScreen(title: 'Derivation Path', seed: seed));
      default:
        return null;
    }
  }
}
