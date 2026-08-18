import 'package:flutter/material.dart';

abstract final class AppColors {
  static const canvas = Color(0xFFFFF8E7);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF243127);
  static const inkMuted = Color(0xFF526158);
  static const primary = Color(0xFF287A4B);
  static const primarySoft = Color(0xFFDCEEDF);
  static const secondary = Color(0xFFC56D24);
  static const secondarySoft = Color(0xFFF7DFC8);
  static const info = Color(0xFF3478B8);
  static const focus = Color(0xFF7357A8);
  static const outline = Color(0xFF66756B);
  static const errorAdult = Color(0xFFA33A3A);
}

abstract final class AppSpacing {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const extraLarge = 32.0;
}

abstract final class AppRadii {
  static const card = 18.0;
  static const panel = 28.0;
}

abstract final class AppMotion {
  static const reduced = Duration(milliseconds: 120);
  static const cardFlip = Duration(milliseconds: 350);
  static const fade = Duration(milliseconds: 250);
  static const pairInspection = Duration(milliseconds: 750);
  static const overlayEntrance = Duration(milliseconds: 250);
  static const celebration = Duration(milliseconds: 2200);
}

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.surface,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.secondary,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.secondarySoft,
      onSecondaryContainer: AppColors.ink,
      error: AppColors.errorAdult,
      onError: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      outline: AppColors.outline,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
