import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF00A550);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color backgroundGrey = Color(0xFFF4F5F7);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundGrey,
      primaryColor: primaryGreen,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark, 
          fontSize: 20, 
          fontWeight: FontWeight.w700
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        error: primaryRed,
        surface: Colors.white,
      ),
    );
  }
}
