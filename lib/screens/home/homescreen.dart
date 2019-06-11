import 'package:flutter/material.dart';
import 'package:hdpm/routes.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _seed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildSeedInputButton(),
              _buildDerivePathButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeedInputButton() {
    return RaisedButton(
      onPressed: () async {
        final seed = await Navigator.pushNamed(context, Routes.seedInput);
        if (seed != null) {
          setState(() => _seed = seed);
        }
      },
      child: Text(_seed == null ? 'Enter Seed' : 'Change Seed'),
    );
  }

  Widget _buildDerivePathButton() {
    return RaisedButton(
      onPressed: _seed == null ? null : () {
        Navigator.pushNamed(context, Routes.derivePath, arguments: _seed);
      },
      child: Text('Derive'),
    );
  }
}
