import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_data.dart';

/// Theme provider for managing app themes
class ThemeNotifier extends StateNotifier<AppThemeType> {
  ThemeNotifier() : super(AppThemeType.defaultBlue);

  /// Change theme
  set theme(AppThemeType themeType) => state = themeType;

  /// Get current color scheme
  AppColorScheme get currentColorScheme => state.colorScheme;
}

/// Dark mode notifier
class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(false);

  /// Toggle dark mode
  void toggle() => state = !state;

  /// Set dark mode
  set isDark(bool value) => state = value;
}

/// Theme provider instance
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

/// Dark mode provider
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier();
});

/// Current color scheme provider (respects dark mode)
final colorSchemeProvider = Provider<AppColorScheme>((ref) {
  final themeType = ref.watch(themeProvider);
  final isDark = ref.watch(darkModeProvider);
  return isDark ? themeType.darkColorScheme : themeType.colorScheme;
});
