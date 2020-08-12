import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoItemRow extends StatelessWidget {
  InfoItemRow(
    this.label,
    this.content, {
    this.colorPrimary = false,
    this.color,
  });
  final String label;
  final String content;
  final Color color;
  final bool colorPrimary;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        Expanded(
          child: Text(
            content,
            textAlign: TextAlign.right,
            style: color != null || colorPrimary
                ? TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color ?? Theme.of(context).primaryColor,
                  )
                : Theme.of(context).textTheme.headline4,
          ),
        ),
      ],
    );
  }
}
