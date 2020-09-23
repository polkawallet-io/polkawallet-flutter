import 'package:flutter/material.dart';

class OutlinedButtonSmall extends StatelessWidget {
  OutlinedButtonSmall(
      {this.content,
      this.active = false,
      this.color,
      this.margin,
      this.onPressed});
  final String content;
  final bool active;
  final Color color;
  final EdgeInsets margin;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    Color primary = color ?? Theme.of(context).primaryColor;
    Color grey = Theme.of(context).unselectedWidgetColor;
    Color white = Theme.of(context).cardColor;
    return GestureDetector(
      child: Container(
        margin: margin ?? EdgeInsets.only(right: 8),
        padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
        decoration: BoxDecoration(
          color: active ? primary : white,
          border: Border.all(color: active ? primary : grey),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Text(content, style: TextStyle(color: active ? white : grey)),
      ),
      onTap: onPressed,
    );
  }
}
