import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/theme_data.dart';

/// Extension to easily access colors from context
extension AppColorsExtension on BuildContext {
  /// Get current color scheme from context
  AppColorScheme get colors {
    if (this is Element) {
      final container = ProviderScope.containerOf(this);
      return container.read(colorSchemeProvider);
    }
    // Fallback to default theme if not in provider scope
    return AppColorScheme.defaultTheme;
  }
}

/// Extension to easily access colors from WidgetRef
extension AppColorsRefExtension on WidgetRef {
  /// Get current color scheme from WidgetRef
  AppColorScheme get colors => watch(colorSchemeProvider);
}
