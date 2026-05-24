import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF0F172A); // dark navy
  static const _accent = Color(0xFFF59E0B); // gold
  static const _surface = Color(0xFF111827);

  static ThemeData lightTheme() => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: _primary,
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.dark,
          primary: _accent,
          secondary: _accent,
          surface: _surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E14),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111827),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0x33FFFFFF), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 1.2),
          ),
          labelStyle: const TextStyle(color: Color(0xFFCBD5E1)),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIconColor: _accent,
        ),
        cardColor: const Color(0xFF111827),
        dividerColor: const Color(0x22FFFFFF),
      );
}
