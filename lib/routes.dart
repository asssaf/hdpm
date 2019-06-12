import 'package:flutter/material.dart';
import 'package:hdpm/screens/derivepath/derivepathscreen.dart';
import 'package:hdpm/screens/home/homescreen.dart';
import 'package:hdpm/screens/seedinput/seedinputscreen.dart';

class Routes {
  static const seedInput = '/seedinput';
  static const derivePath = '/derivepath';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen(title: 'hdpm'));
      case Routes.seedInput:
        return MaterialPageRoute(builder: (_) => SeedInputScreen(title: 'Seed Input'));
      case Routes.derivePath:
        var seed = settings.arguments;
        return MaterialPageRoute(builder: (_) => DerivePathScreen(title: 'Derive Path', seed: seed));
    }
  }
}
