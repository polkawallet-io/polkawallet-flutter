import 'package:flutter/material.dart';

Widget formulaInput({lable}){
  return Expanded(
    child: Column(
      children: <Widget>[
        TextField(
          textAlign: TextAlign.center
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            lable,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10
            )
          ),
        )
      ],
    ),
  );
}