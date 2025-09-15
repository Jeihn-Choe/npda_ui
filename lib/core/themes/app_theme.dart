import 'package:flutter/material.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.celltrionGreen,
        brightness: Brightness.light,
        primary: AppColors.celltrionGreen,
        background: AppColors.white, // 위젯들의 기본 배경색
      ),
      scaffoldBackgroundColor: AppColors.grey100, // 화면의 기본 배경색

      fontFamily: 'Pretendard', // 폰트 설정 (pubspec.yaml에 추가 필요)

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.celltrionBlack),
        bodyMedium: TextStyle(color: AppColors.darkGrey),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.celltrionGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.celltrionGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.celltrionGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.grey400),
      ),
    );
  }
}
