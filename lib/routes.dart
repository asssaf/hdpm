import 'package:flutter/material.dart';
import 'package:hdpm/models/secretitem.dart';
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
        final args = settings.arguments as Map<String, Object>;
        final title = args['title'] ?? 'New Item';
        final seed = args['seed'];
        final secretItem = args['secretItem'] ?? SecretItem();
        return MaterialPageRoute(builder: (_) => EditSecretScreen(title: title, seed: seed, secretItem: secretItem));
      default:
        return null;
    }
  }
}
