import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2ecc71);
  static const Color primaryColorDark = Color(0xFF27ae60);

  static final TextTheme _textTheme = GoogleFonts.latoTextTheme();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      textTheme: _textTheme.apply(bodyColor: Colors.black),
      elevatedButtonTheme: _elevatedButtonTheme(primaryColor),
      textButtonTheme: _textButtonTheme(primaryColor),
      inputDecorationTheme: _inputDecorationTheme(primaryColor),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColorDark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: _textTheme.apply(bodyColor: Colors.white),
      elevatedButtonTheme: _elevatedButtonTheme(primaryColorDark),
      textButtonTheme: _textButtonTheme(primaryColorDark),
      inputDecorationTheme: _inputDecorationTheme(primaryColorDark),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color color) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color color) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: color,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color color) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: color),
      ),
    );
  }
}
