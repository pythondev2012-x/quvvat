import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Color(0xFFD71920);
  static const Color redBright = Color(0xFFFF2F3B);
  static const Color black = Color(0xFF0B0B0C);
  static const Color ink = Color(0xFF17171A);
  static const Color muted = Color(0xFF6B6B70);
  static const Color line = Color(0xFFE4E4E1);
  static const Color soft = Color(0xFFF5F4F1);
  static const Color white = Colors.white;
  static const Color green = Color(0xFF1B8A4C);
  static const Color orange = Color(0xFFE07A00);
  static const Color blue = Color(0xFF1D63C7);
}

class AppText {
  static const String displayFamily = 'Unbounded';
  static const String bodyFamily = 'Onest';

  static TextStyle display({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.black,
    double height = 1.15,
    double letterSpacing = -0.5,
  }) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.black,
    double height = 1.4,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.red,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.red,
      onPrimary: Colors.white,
      secondary: AppColors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: AppText.bodyFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.soft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: AppText.body(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(
            fontFamily: AppText.bodyFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.line),
          textStyle: const TextStyle(
            fontFamily: AppText.bodyFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.red),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: AppText.bodyFamily,
          color: Colors.white,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.red.withValues(alpha: 0.10),
        elevation: 0,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppText.bodyFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.soft,
        selectedColor: AppColors.red.withValues(alpha: 0.12),
        side: BorderSide.none,
        labelStyle: AppText.body(size: 13, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
