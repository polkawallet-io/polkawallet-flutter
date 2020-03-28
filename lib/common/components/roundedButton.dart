import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({this.text, this.onPressed, this.icon, this.color, this.expand})
      : assert(text != null);

  final String text;
  final Function onPressed;
  final Widget icon;
  final Color color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    List<Widget> row = <Widget>[];
    if (icon != null) {
      row.add(Container(
        width: 32,
        child: icon,
      ));
    }
    row.add(Text(
      text,
      style: Theme.of(context).textTheme.button,
    ));
    return RaisedButton(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
      color: color ?? Colors.purple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row,
      ),
      onPressed: onPressed,
    );
  }
}
