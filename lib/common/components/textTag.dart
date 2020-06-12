import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextTag extends StatelessWidget {
  TextTag(this.text, {this.margin, this.padding, this.color, this.fontSize});
  final String text;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 10,
          color: Theme.of(context).cardColor,
        ),
      ),
      margin: margin ?? EdgeInsets.all(2),
      padding: padding ?? EdgeInsets.fromLTRB(4, 2, 4, 2),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}
