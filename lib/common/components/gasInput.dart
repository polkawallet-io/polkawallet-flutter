
import 'package:flutter/material.dart';

Widget gesInput(title,subtile){
  return ListTile(
    leading: Text(
      title,
      style: TextStyle(
        fontSize: 14
      )
    ),
    title: TextField(
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14
      ),
    ),
    trailing: Text(
      subtile,
      style: TextStyle(
        fontSize: 14
      )
    ),
  );
}