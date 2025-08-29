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

/// Theme provider instance
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  return ThemeNotifier();
});

/// Current color scheme provider
final colorSchemeProvider = Provider<AppColorScheme>((ref) {
  final themeType = ref.watch(themeProvider);
  return themeType.colorScheme;
});
