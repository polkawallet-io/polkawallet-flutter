import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({
    this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.expand,
    this.submitting = false,
  }) : assert(text != null);

  final String text;
  final Function onPressed;
  final Widget icon;
  final Color color;
  final bool expand;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    List<Widget> row = <Widget>[];
    if (submitting) {
      row.add(CupertinoActivityIndicator());
    }
    if (icon != null) {
      row.add(Container(
        width: 32,
        child: icon,
      ));
    }
    row.add(Text(
      text ?? '',
      style: Theme.of(context).textTheme.button,
    ));
    return RaisedButton(
      padding: EdgeInsets.only(top: 12, bottom: 12),
      color: color ?? Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row,
      ),
      onPressed: submitting ? null : onPressed,
    );
  }
}
