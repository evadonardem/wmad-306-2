import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium minimalist light theme — Inter for body, Poppins for headings.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: base.textTheme.displayLarge,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: base.textTheme.headlineLarge,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: base.textTheme.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: base.textTheme.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: base.textTheme.titleLarge,
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFFEF4444),
        secondary: const Color(0xFF3B82F6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6890F0), width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.black38),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFEF4444),
        foregroundColor: Colors.white,
      ),
    );
  }
}
