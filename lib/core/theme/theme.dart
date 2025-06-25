import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xff2a5a46),

    inversePrimary: Color(0xff000000),

    onSurface: Color(0xffF2F2F7),
    secondary: Color(0xff636363),
    error: Color(0xffe53935),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    surface: Colors.black,

    primary: Color(0xff4CAF8C),

    inversePrimary: Color(0xffFFFFFF),

    onSurface: Color(0xff1C1C1E),
    secondary: Color(0xff636363),
    error: Color(0xffff5252),
  ),
);
