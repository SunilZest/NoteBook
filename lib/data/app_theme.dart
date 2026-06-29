import 'package:flutter/material.dart';

class AppColors {
  // Common Accents
  static const Color crimsonRed = Color(0xFFFF334B);
  static const Color softEmerald = Color(0xFF10B981);
  static const Color warmAmber = Color(0xFFF59E0B);

  // Dark Theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2A2A2A);

  // Light Theme
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
}

class AppTextStyles {
  static const String fontFamily = 'Roboto'; 

  // Brand Main Title (Using FontWeight.w900 for punchy weight)
  static const TextStyle brandHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.crimsonRed,
    letterSpacing: 2.0,
  );

  // Note Card Title (Explicitly utilizing requested FontWeight.w700)
  static const TextStyle noteTitleDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle noteTitleLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Note Card Body Text
  static const TextStyle noteBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Commit / Action Buttons
  static const TextStyle actionButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 1.0,
  );
}

class AppThemes {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      dividerColor: AppColors.darkBorder,
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      dividerColor: AppColors.lightBorder,
      useMaterial3: true,
    );
  }
}