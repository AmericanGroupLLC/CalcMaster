import 'package:flutter/material.dart';
import 'tokens.dart';

ThemeData buildAppTheme() {
  const base = ColorScheme.dark(
    surface: AppColors.bg,
    primary: AppColors.accentPrimary,
    onPrimary: Colors.white,
    secondary: AppColors.success,
    onSecondary: Colors.black,
    error: AppColors.danger,
    onError: Colors.white,
    onSurface: AppColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: base,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.text,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.text,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        color: AppColors.textMuted,
      ),
    ),
  );
}
