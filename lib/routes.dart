import 'package:flutter/material.dart';
import 'package:hdpm/screens/home/homescreen.dart';
import 'package:hdpm/screens/seedinput/seedinputscreen.dart';
import 'package:hdpm/screens/derivepath/derivepathscreen.dart';

class Routes {
  static const seedInput = "/seedinput";
  static const derivePath = "/derivepath";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => HomeScreen(title: 'hdpm'));
      case Routes.seedInput:
        return MaterialPageRoute(builder: (context) => SeedInputScreen(title: 'Seed Input'));
      case Routes.derivePath:
        var seed = settings.arguments;
        return MaterialPageRoute(builder: (context) => DerivePathScreen(title: 'Derive Path', seed: seed));
    }
  }
}
