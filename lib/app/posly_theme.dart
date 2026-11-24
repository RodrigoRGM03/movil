import 'package:flutter/material.dart';

abstract final class PoslyColors {
  static const navy = Color(0xFF101B2F);
  static const turquoise = Color(0xFF03BBD7);
  static const white = Color(0xFFFFFFFF);
  static const blueGray = Color(0xFFDBDFE8);
  static const lightBackground = Color(0xFFFAF7EE);
  static const darkBackground = Color(0xFF1A1F23);
}

abstract final class PoslyTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: PoslyColors.lightBackground,
    surface: PoslyColors.white,
    foreground: PoslyColors.navy,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: PoslyColors.darkBackground,
    surface: PoslyColors.navy,
    foreground: PoslyColors.white,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color foreground,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: PoslyColors.turquoise,
      onPrimary: PoslyColors.navy,
      secondary: PoslyColors.navy,
      onSecondary: PoslyColors.white,
      error: brightness == Brightness.light
          ? PoslyColors.navy
          : PoslyColors.white,
      onError: PoslyColors.turquoise,
      surface: surface,
      onSurface: foreground,
      outline: PoslyColors.blueGray,
      surfaceContainerHighest: brightness == Brightness.light
          ? PoslyColors.blueGray
          : const Color(0xFF303A46),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: brightness == Brightness.light
                ? PoslyColors.blueGray
                : const Color(0xFF303A46),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PoslyColors.blueGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PoslyColors.blueGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PoslyColors.turquoise, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PoslyColors.turquoise,
          foregroundColor: PoslyColors.navy,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PoslyColors.turquoise,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: PoslyColors.blueGray),
    );
  }
}
