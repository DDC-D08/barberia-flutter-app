import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF0F172A); // navy/ink
  static const _accent = Color(0xFF10B981); // emerald green

  static ThemeData lightTheme() => ThemeData(
        brightness: Brightness.light,
        primaryColor: _primary,
        colorScheme: ColorScheme.fromSeed(seedColor: _primary, primary: _primary, secondary: _accent),
        appBarTheme: const AppBarTheme(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: Colors.black54),
        ),
        // Card theming handled by per-widget Card constructors for SDK compatibility
        
      );
}
