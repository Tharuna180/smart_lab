import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo,
    textTheme: GoogleFonts.poppinsTextTheme(),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
  );
}
