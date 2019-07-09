import 'package:flutter/material.dart';

class LabeledIntSlider extends StatelessWidget {
  LabeledIntSlider({this.label, this.value, this.min, this.max, this.onChanged});

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
          Expanded(
            child: Slider(
              label: value.toString(),
              value: value.toDouble(),
              min: min.toDouble() - 0.1,
              max: max.toDouble() + 0.1,
              divisions: max - min,
              onChanged: (value) => onChanged(value.round()),
            ),
          ),
          SizedBox(
            width: 16, //TODO label width property
            child: Text(
              value.toString(),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
