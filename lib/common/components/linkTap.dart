import 'package:flutter/material.dart';

Widget linkTap(name,{onTap}){
  return GestureDetector(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
      ),
    ),
    onTap: onTap,
  );
}