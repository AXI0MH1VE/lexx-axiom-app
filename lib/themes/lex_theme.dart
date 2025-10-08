import 'package:flutter/material.dart';

final lexTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF69B4), // Hot pink
    primary: const Color(0xFFFF69B4),
    surface: Colors.white.withOpacity(0.05),
    background: Colors.black.withOpacity(0.9),
  ),
  scaffoldBackgroundColor: Colors.black.withOpacity(0.85),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    bodySmall: TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.1),
      foregroundColor: const Color(0xFFFF69B4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: const Color(0xFFFF69B4).withOpacity(0.3)),
    ),
    hintStyle: const TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
  ),
);
