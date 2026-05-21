import 'package:flutter/material.dart';

/// Tema visual de ZapalloAI
/// Paleta: verde agrícola + tierra + acento ámbar
class ZapalloTheme {
  // ── Colores primarios ──────────────────────────────────────────
  static const Color primary = Color(0xFF2D6A4F);       // Verde zapallo oscuro
  static const Color primaryLight = Color(0xFF52B788);  // Verde medio
  static const Color primarySurface = Color(0xFFD8F3DC); // Verde muy claro

  static const Color secondary = Color(0xFFE9A03B);     // Ámbar/naranja tierra
  static const Color secondaryLight = Color(0xFFFFF3CD);

  static const Color error = Color(0xFFD62828);
  static const Color warning = Color(0xFFF4A261);
  static const Color success = Color(0xFF52B788);

  // ── Neutrales ─────────────────────────────────────────────────
  static const Color surface = Color(0xFFF8FAF8);
  static const Color background = Color(0xFFF2F7F2);
  static const Color cardBg = Colors.white;

  static const Color textPrimary = Color(0xFF1B2D25);
  static const Color textSecondary = Color(0xFF5C6B63);
  static const Color textHint = Color(0xFF9DB3A5);

  // ── Gradientes ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
  );

  // ── Tema principal ────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Outfit',

      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primarySurface,
        onPrimaryContainer: primary,
        secondary: secondary,
        onSecondary: Colors.white,
        error: error,
        surface: surface,
        onSurface: textPrimary,
      ),

      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8F0E8), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          color: Colors.white,
        ),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: textPrimary, fontFamily: 'Outfit',
        ),
        displayMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: textPrimary, fontFamily: 'Outfit',
        ),
        headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: textPrimary, fontFamily: 'Outfit',
        ),
        titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: textPrimary, fontFamily: 'Outfit',
        ),
        titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: textPrimary, fontFamily: 'Outfit',
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: textPrimary, fontFamily: 'Outfit',
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: textSecondary, fontFamily: 'Outfit',
        ),
        labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: textPrimary, fontFamily: 'Outfit',
        ),
      ),
    );
  }
}
