

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Varela',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: HexColor('0070CC'),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontFamily: 'Varela',
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
);



ThemeData darkMode = ThemeData(
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Varela',
  scaffoldBackgroundColor: HexColor('161616'),
  colorScheme: ColorScheme.dark(
    primary: HexColor('50b0ff').withOpacity(.8),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: HexColor('161616'),
    elevation: 0,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: HexColor('161616'),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: HexColor('161616'),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: const TextStyle(
      fontSize: 18.0,
      fontFamily: 'Varela',
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
);