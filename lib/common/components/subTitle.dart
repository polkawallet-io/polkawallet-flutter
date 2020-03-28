import 'package:flutter/material.dart';

Widget subTitle(name,{alignment = Alignment.center}){
  return Container(
    padding: const EdgeInsets.only(top:20),
    alignment: alignment,
    child: Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16
      ),
    )
  );
}