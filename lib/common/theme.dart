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

const MaterialColor kusamaBlack = const MaterialColor(
  0xFF222222,
  const <int, Color>{
    50: const Color(0xFF555555),
    100: const Color(0xFF444444),
    200: const Color(0xFF444444),
    300: const Color(0xFF333333),
    400: const Color(0xFF333333),
    500: const Color(0xFF222222),
    600: const Color(0xFF111111),
    700: const Color(0xFF111111),
    800: const Color(0xFF000000),
    900: const Color(0xFF000000),
  },
);

final appThemeKusama = ThemeData(
  primarySwatch: kusamaBlack,
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
  primarySwatch: ZurichLion,
  textTheme: TextTheme(
    headline1: TextStyle(
      fontSize: 66,
      color: ZurichLion.shade500,
    ),
    headline2: TextStyle(
      fontSize: 22,
      color: ZurichLion.shade500,
    ),
    headline3: TextStyle(
      fontSize: 19,
      color: ZurichLion.shade500,
    ),
    headline4: TextStyle(
      fontSize: 14,
      color: ZurichLion.shade500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: ZurichLion.shade50,
      onPrimary: ZurichLion.shade500,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    // foregroundColor: Colors.orange, // this gets for some reason ignored and we have to define iconTheme and textTheme
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(
      color: ZurichLion.shade500,
    ),
    shadowColor: Colors.transparent,
    textTheme: TextTheme(
      headline6: TextStyle(
        // it's not obvious but appBar uses headline6
        fontSize: 19,
        color: ZurichLion.shade500,
      ),
    ),
    centerTitle: true,
  ),
  scaffoldBackgroundColor: Colors.white,
);

const MaterialColor ZurichLion = const MaterialColor(
  0xff4374A3,
  const <int, Color>{
    50: const Color(0xffF4F8F9), // <--- used for light blue buttons (i.e. secondary buttons)
    100: const Color(0xffF4F8F9),
    200: const Color(0xffF4F8F9),
    300: const Color(0xffF4F8F9),
    400: const Color(0xFF3880BD), // <--- starting color of gradient
    500: const Color(0xff4374A3), // <--- main color for almost all texts
    600: const Color(0xFF3969AC), // <--- end color of gradient
    700: const Color(0xFF3969AC),
    800: const Color(0xFF3969AC),
    900: const Color(0xFF000022), // <--- dark blue for the scan bottomButtonBar icon
  },
);
const Color encointerGrey = Color(0xff666666);
const Color encointerBlack = Color(0xff353535);
const Color encointerLightBlue = Color(0xffF4F8F9); // ZurichLion.shade(50)
const Color encointerBlue = Color(0xff4374A3); // ZurichLion.shade(500)

final appThemeLaminar = ThemeData(
  primarySwatch: Colors.deepPurple,
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

// TODO later: maybe turn into a function that takes the 2 colors and returns the gradient
final primaryGradient = LinearGradient(
  begin: Alignment(-.9, 0),
  end: Alignment(0.1, -.1),
  colors: <Color>[ZurichLion.shade400, ZurichLion.shade600],
);
