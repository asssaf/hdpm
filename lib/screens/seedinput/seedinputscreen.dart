import 'package:flutter/material.dart';
import 'package:hdpm/screens/seedinput/components/seedinputform.dart';

class SeedInputScreen extends StatefulWidget {
  SeedInputScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SeedInputScreenState createState() => _SeedInputScreenState();
}

class _SeedInputScreenState extends State<SeedInputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: SeedInputForm(onSave: onSave),
      ),
    );
  }

  void onSave(String seed) {
    Navigator.pop(context, seed);
  }
}