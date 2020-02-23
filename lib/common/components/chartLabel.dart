import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChartLabel extends StatelessWidget {
  ChartLabel({this.name, this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 4,
          width: 24,
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 3, color: color)),
          ),
        ),
        Text(name),
      ],
    );
  }
}
