import 'package:flutter/material.dart';

/// 버블톡 색상 (하늘색 계열). 화면 코드에서는 이 값을 직접 쓰거나 Theme.of(context) 를 쓴다.
/// 앱 아이콘(tool/generate_app_icon_test.dart)도 같은 색을 쓴다.
abstract final class AppColors {
  static const primary = Color(0xFF2E9BF0);
  static const primaryDark = Color(0xFF1C7FD6);
  static const primaryLight = Color(0xFFE3F2FE);
  static const background = Colors.white;
  static const chatBackground = Color(0xFFEEF5FC);
  static const partnerBubble = Colors.white;
  static const border = Color(0xFFE5EBF2);
  static const textStrong = Color(0xFF1A2433);
  static const textWeak = Color(0xFF8793A3);
  static const badge = Color(0xFFFF5A5F);

  /// 내 말풍선 그라데이션
  static const myBubble = LinearGradient(
    colors: [Color(0xFF52BDFF), Color(0xFF2E9BF0)],
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
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textWeak,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textWeak,
          ),
        ),
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
