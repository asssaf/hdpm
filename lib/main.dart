import 'package:flutter/material.dart';
import 'package:hdpm/routes.dart';

void main() => runApp(HdpmApp());

class HdpmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hdpm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
