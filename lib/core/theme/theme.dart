import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    background: Colors.white,

    primary: Color(0xff2B654D),
    onPrimary: Color(0xffFFFFFF),

    surface: Color(0xffF2F2F7),
    onSurface: Color(0xff8A8A8E),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    background: Colors.black,

    primary: Color(0xff4CAF8C),
    onPrimary: Color(0xff000000),

    surface: Color(0xff1C1C1E),
    onSurface: Color(0xffA2A2A7),
  ),
);
