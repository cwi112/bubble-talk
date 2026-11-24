import 'package:flutter/material.dart';

/// 버블톡 색상. 화면 코드에서는 이 값을 직접 쓰거나 Theme.of(context) 를 쓴다.
abstract final class AppColors {
  static const primary = Color(0xFF5B6CFF);
  static const primaryDark = Color(0xFF4353E8);
  static const background = Colors.white;
  static const chatBackground = Color(0xFFF1F3FB);
  static const partnerBubble = Colors.white;
  static const border = Color(0xFFE8EAF2);
  static const textStrong = Color(0xFF1C1F2E);
  static const textWeak = Color(0xFF8A8FA3);
  static const badge = Color(0xFFFF5A5F);

  /// 내 말풍선 그라데이션
  static const myBubble = LinearGradient(
    colors: [Color(0xFF6A7BFF), Color(0xFF5B6CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textStrong,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textStrong),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
    );
  }
}
