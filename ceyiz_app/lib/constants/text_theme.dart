import 'package:flutter/material.dart';

import 'app_colors.dart';

class TextThemeLight {
  static TextTheme get textTheme => TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTextColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.primaryTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.secondaryTextColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryTextColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.secondaryTextColor,
        ),
      );
}
