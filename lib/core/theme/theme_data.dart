import 'package:flutter/material.dart';

/// Application color schemes for different themes
class AppColorScheme {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color secondaryDark;
  final Color secondaryLight;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color error;
  final Color warning;
  final Color success;
  final Color info;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color border;
  final Color borderFocus;
  final Color borderError;
  final Color white;
  final Color black;
  final Color grey50;
  final Color grey100;
  final Color grey200;
  final Color grey300;
  final Color grey400;
  final Color grey500;
  final Color grey600;
  final Color grey700;
  final Color grey800;
  final Color grey900;

  const AppColorScheme({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.secondaryDark,
    required this.secondaryLight,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.error,
    required this.warning,
    required this.success,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.border,
    required this.borderFocus,
    required this.borderError,
    required this.white,
    required this.black,
    required this.grey50,
    required this.grey100,
    required this.grey200,
    required this.grey300,
    required this.grey400,
    required this.grey500,
    required this.grey600,
    required this.grey700,
    required this.grey800,
    required this.grey900,
  });

  /// Default blue theme (current)
  static const defaultTheme = AppColorScheme(
    primary: Color(0xFF2563EB),
    primaryDark: Color(0xFF1E40AF),
    primaryLight: Color(0xFF3B82F6),
    secondary: Color(0xFF64748B),
    secondaryDark: Color(0xFF475569),
    secondaryLight: Color(0xFF94A3B8),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey50: Color(0xFFF8FAFC),
    grey100: Color(0xFFF1F5F9),
    grey200: Color(0xFFE2E8F0),
    grey300: Color(0xFFCBD5E1),
    grey400: Color(0xFF94A3B8),
    grey500: Color(0xFF64748B),
    grey600: Color(0xFF475569),
    grey700: Color(0xFF334155),
    grey800: Color(0xFF1E293B),
    grey900: Color(0xFF0F172A),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textTertiary: Color(0xFF94A3B8),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    borderFocus: Color(0xFF2563EB),
    borderError: Color(0xFFEF4444),
  );

  /// Green theme
  static const greenTheme = AppColorScheme(
    primary: Color(0xFF059669),
    primaryDark: Color(0xFF047857),
    primaryLight: Color(0xFF10B981),
    secondary: Color(0xFF6B7280),
    secondaryDark: Color(0xFF4B5563),
    secondaryLight: Color(0xFF9CA3AF),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey50: Color(0xFFF9FAFB),
    grey100: Color(0xFFF3F4F6),
    grey200: Color(0xFFE5E7EB),
    grey300: Color(0xFFD1D5DB),
    grey400: Color(0xFF9CA3AF),
    grey500: Color(0xFF6B7280),
    grey600: Color(0xFF4B5563),
    grey700: Color(0xFF374151),
    grey800: Color(0xFF1F2937),
    grey900: Color(0xFF111827),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    background: Color(0xFFF9FAFB),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF3F4F6),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textTertiary: Color(0xFF9CA3AF),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    borderFocus: Color(0xFF059669),
    borderError: Color(0xFFEF4444),
  );

  /// Purple theme
  static const purpleTheme = AppColorScheme(
    primary: Color(0xFF7C3AED),
    primaryDark: Color(0xFF6D28D9),
    primaryLight: Color(0xFF8B5CF6),
    secondary: Color(0xFF6B7280),
    secondaryDark: Color(0xFF4B5563),
    secondaryLight: Color(0xFF9CA3AF),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey50: Color(0xFFFAF9FF),
    grey100: Color(0xFFF5F3FF),
    grey200: Color(0xFFEDE9FE),
    grey300: Color(0xFFDDD6FE),
    grey400: Color(0xFFC4B5FD),
    grey500: Color(0xFFA78BFA),
    grey600: Color(0xFF8B5CF6),
    grey700: Color(0xFF7C3AED),
    grey800: Color(0xFF6D28D9),
    grey900: Color(0xFF581C87),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    background: Color(0xFFFAF9FF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F3FF),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    textTertiary: Color(0xFF9CA3AF),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFEDE9FE),
    borderFocus: Color(0xFF7C3AED),
    borderError: Color(0xFFEF4444),
  );

  /// Orange theme
  static const orangeTheme = AppColorScheme(
    primary: Color(0xFFEA580C),
    primaryDark: Color(0xFFC2410C),
    primaryLight: Color(0xFFF97316),
    secondary: Color(0xFF6B7280),
    secondaryDark: Color(0xFF4B5563),
    secondaryLight: Color(0xFF9CA3AF),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey50: Color(0xFFFFFAF5),
    grey100: Color(0xFFFEF3E2),
    grey200: Color(0xFFFED7AA),
    grey300: Color(0xFFFDBA74),
    grey400: Color(0xFFFB923C),
    grey500: Color(0xFFF97316),
    grey600: Color(0xFFEA580C),
    grey700: Color(0xFFC2410C),
    grey800: Color(0xFF9A3412),
    grey900: Color(0xFF7C2D12),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    background: Color(0xFFFFFAF5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFEF3E2),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    textTertiary: Color(0xFF9CA3AF),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFFED7AA),
    borderFocus: Color(0xFFEA580C),
    borderError: Color(0xFFEF4444),
  );

  /// Dark theme
  static const darkTheme = AppColorScheme(
    primary: Color(0xFF3B82F6),
    primaryDark: Color(0xFF1D4ED8),
    primaryLight: Color(0xFF60A5FA),
    secondary: Color(0xFF9CA3AF),
    secondaryDark: Color(0xFF6B7280),
    secondaryLight: Color(0xFFD1D5DB),
    white: Color(0xFF1F2937),
    black: Color(0xFFFFFFFF),
    grey50: Color(0xFF1F2937),
    grey100: Color(0xFF374151),
    grey200: Color(0xFF4B5563),
    grey300: Color(0xFF6B7280),
    grey400: Color(0xFF9CA3AF),
    grey500: Color(0xFFD1D5DB),
    grey600: Color(0xFFE5E7EB),
    grey700: Color(0xFFF3F4F6),
    grey800: Color(0xFFF9FAFB),
    grey900: Color(0xFFFFFFFF),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    background: Color(0xFF111827),
    surface: Color(0xFF1F2937),
    surfaceVariant: Color(0xFF374151),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFD1D5DB),
    textTertiary: Color(0xFF9CA3AF),
    textOnPrimary: Color(0xFF1F2937),
    border: Color(0xFF4B5563),
    borderFocus: Color(0xFF3B82F6),
    borderError: Color(0xFFEF4444),
  );
}

/// Theme types enum
enum AppThemeType { defaultBlue, green, purple, orange, dark }

/// Extension to get color scheme from theme type
extension AppThemeTypeExtension on AppThemeType {
  AppColorScheme get colorScheme {
    switch (this) {
      case AppThemeType.defaultBlue:
        return AppColorScheme.defaultTheme;
      case AppThemeType.green:
        return AppColorScheme.greenTheme;
      case AppThemeType.purple:
        return AppColorScheme.purpleTheme;
      case AppThemeType.orange:
        return AppColorScheme.orangeTheme;
      case AppThemeType.dark:
        return AppColorScheme.darkTheme;
    }
  }

  String get name {
    switch (this) {
      case AppThemeType.defaultBlue:
        return 'Mavi';
      case AppThemeType.green:
        return 'Yeşil';
      case AppThemeType.purple:
        return 'Mor';
      case AppThemeType.orange:
        return 'Turuncu';
      case AppThemeType.dark:
        return 'Karanlık';
    }
  }
}
