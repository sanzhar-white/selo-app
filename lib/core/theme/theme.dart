import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    background: Colors.white,

    primary: Color(0xff2B654D),
    onPrimary: Color(0xffFFFFFF),

    inversePrimary: Color(0xff000000),

    onSurface: Color(0xffF2F2F7),
    secondary: Color(0xff636363),
    error: Color(0xffe53935),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    background: Colors.black,

    primary: Color(0xff4CAF8C),
    onPrimary: Color(0xff000000),

    inversePrimary: Color(0xffFFFFFF),

    onSurface: Color(0xff1C1C1E),
    secondary: Color(0xff636363),
    error: Color(0xffff5252),
  ),
);
