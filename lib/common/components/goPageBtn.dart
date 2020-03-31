import 'package:flutter/material.dart';

Widget goPageBtn(name,{onTap,textAlign = TextAlign.right}){
  return Expanded(
    child: GestureDetector(
      child: Text(
        name,
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18
        ),
      ),
      onTap: onTap,
    )
  );
}