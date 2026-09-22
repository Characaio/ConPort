import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Montserrat',

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2B5137),
        tertiary: Color(0xFF254016),
        onPrimary: Colors.white,
        secondary: Color(0xFF402216),
        surface: Color(0xFFF5F5F5),
        onSurface: Color(0xFF1C1B1F),
        error: Color(0xFFB00020),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4BD972),
        tertiary: Color(0xFF80D94C),
        onPrimary: Colors.black,
        secondary: Color(0xFFD9844C),
        surface: Color(0xFF121212),
        onSurface: Colors.white,
        error: Color(0xFFCF6679),
      ),
    );
  }
}
