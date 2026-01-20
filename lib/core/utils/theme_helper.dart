import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../theme/theme_data.dart';

/// Helper class to get localized theme names
class ThemeHelper {
  /// Get localized theme name
  static String getThemeName(BuildContext context, AppThemeType themeType) {
    final l10n = AppLocalizations.of(context)!;

    switch (themeType) {
      case AppThemeType.defaultBlue:
        return l10n.themeBlue;
      case AppThemeType.green:
        return l10n.themeGreen;
      case AppThemeType.purple:
        return l10n.themePurple;
      case AppThemeType.orange:
        return l10n.themeOrange;
    }
  }
}
