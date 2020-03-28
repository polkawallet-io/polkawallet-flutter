import 'package:flutter/material.dart';

Widget checkRule(content){
  return ListTile(
    leading: Checkbox(
      value: false,
      onChanged: (newValue){}
    ),
    title: Text(
      content,
      style: TextStyle(
        fontSize: 14
      )
    ),
  );
}