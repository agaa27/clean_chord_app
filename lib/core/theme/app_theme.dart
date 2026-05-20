import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Orbitron')),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.cyanAccent,
    ),
  );
}
