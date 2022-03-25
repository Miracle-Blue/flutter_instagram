import 'package:flutter/material.dart';

// * colors
const Color colorOne = Color(0xff833ab4);
const Color colorTwo = Color(0xffc13584);

// const Color colorTwo = Color(0xfffcaf45);
// const Color colorOne = Color(0xfff56040);

// * fonts
const String fontHeader = "Billabong";

final ThemeData themeLight = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.white,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: colorTwo,
  ),
);
