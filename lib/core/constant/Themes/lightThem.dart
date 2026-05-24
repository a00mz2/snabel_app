// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: "Hanimation Arabic",

  primaryColor: const Color(0xffF39316),
  shadowColor: Color(0xffDDF0E6),

  primaryColorDark: Color(0xff3C2313),
  primaryColorLight: Colors.white,

  scaffoldBackgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: Color(0xff00361A)),

  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xff01A850),
    textTheme: ButtonTextTheme.primary,
  ),
  splashColor: const Color.fromARGB(0, 139, 255, 193),

  //=============================================================appbat them
  appBarTheme: AppBarTheme(
    iconTheme: const IconThemeData(color: Color(0xff00361A)),
    color: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: MyFontWeight.regular,
      color: const Color.fromARGB(255, 255, 165, 68),
      fontFamily: "Cairo",
    ),
  ),

  //1=============================================================================== text them
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontWeight: MyFontWeight.bold,
      fontSize: 24,
      color: Color(0xff211F20),
    ),
    titleMedium: TextStyle(
      color: Colors.black.withOpacity(0.7),
      fontSize: 20,
      fontWeight: MyFontWeight.semiBold,
    ),
    titleSmall: TextStyle(
      color: Color(0xff292929),
      fontSize: 14,
      fontWeight: MyFontWeight.medium,
    ),
    //==============================================================================
    bodyLarge: const TextStyle(
      color: Color.fromARGB(255, 107, 118, 155),
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),

    bodyMedium: TextStyle(
      fontSize: 16,
      color: const Color(0xff7C7C7C),
      fontWeight: MyFontWeight.regular,
    ),

    bodySmall: const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w100,
    ),

    //==============================================================================
    //النص الذي يكتب بداخل حقل الادخال
    displayMedium: const TextStyle(
      fontSize: 15,
      color: Color.fromARGB(255, 35, 41, 70),
    ),
  ),
);

class MyFontWeight {
  static FontWeight extraLight = FontWeight.w200;
  static FontWeight light = FontWeight.w300;
  static FontWeight regular = FontWeight.w400;
  static FontWeight medium = FontWeight.w500;
  static FontWeight semiBold = FontWeight.w600;
  static FontWeight bold = FontWeight.w700;
  static FontWeight extraBold = FontWeight.w800;
  static FontWeight black = FontWeight.w900;
}
