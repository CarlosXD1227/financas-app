import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF26A69A);
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Colors.white;
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
  static const Color saving = Color(0xFF7E57C2);
  static const Color text = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double cardElevation = 2.0;
}
