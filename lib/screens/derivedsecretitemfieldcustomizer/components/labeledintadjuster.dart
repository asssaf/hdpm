import 'package:flutter/material.dart';

class LabeledIntAdjuster extends StatelessWidget {
  LabeledIntAdjuster({this.label, this.value, this.min, this.max, this.onChanged});

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Text(label),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: value < max ? _increment : null,
          ),
          Text(value.toString()),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: value > min ? _decrement : null,
          ),
        ],
      ),
    );
  }

  void _increment() {
    if (value < max) {
      onChanged(value + 1);
    }
  }

  void _decrement() {
    if (value > min) {
      onChanged(value - 1);
    }
  }
}
