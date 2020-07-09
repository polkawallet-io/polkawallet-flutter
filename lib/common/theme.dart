import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.pink,
  textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24,
      ),
      headline2: TextStyle(
        fontSize: 22,
      ),
      headline3: TextStyle(
        fontSize: 20,
      ),
      headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      button: TextStyle(
        color: Colors.white,
        fontSize: 18,
      )),
);
// TODO: dark theme has display issues
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.pink,
  textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24,
      ),
      headline2: TextStyle(
        fontSize: 22,
      ),
      headline3: TextStyle(
        fontSize: 20,
      ),
      headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      button: TextStyle(
        color: Colors.white,
        fontSize: 18,
      )),
);

final appThemeKusama = ThemeData(
  primaryColorDark: Colors.pink[900],
  primaryColorLight: Colors.pink[600],
  primaryColor: Colors.pink[800],
  accentColor: Colors.pink[700],
  textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24,
      ),
      headline2: TextStyle(
        fontSize: 22,
      ),
      headline3: TextStyle(
        fontSize: 20,
      ),
      headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      button: TextStyle(
        color: Colors.white,
        fontSize: 18,
      )),
);

final appThemeEncointer = ThemeData(
  primarySwatch: Colors.indigo,
  textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: 24,
      ),
      headline2: TextStyle(
        fontSize: 22,
      ),
      headline3: TextStyle(
        fontSize: 20,
      ),
      headline4: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      button: TextStyle(
        color: Colors.white,
        fontSize: 18,
      )),
);
