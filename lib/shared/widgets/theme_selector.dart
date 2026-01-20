import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/theme_data.dart';
import '../../../core/utils/theme_helper.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

/// Theme selector widget for changing app themes
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = ref.watch(darkModeProvider);
    final colors = ref.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark mode toggle
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingS,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  isDarkMode ? PhosphorIconsFill.moon : PhosphorIconsFill.sun,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Text(
                    l10n.darkMode,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(darkModeProvider.notifier).isDark = value;
                  },
                  activeColor: colors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Wrap(
            spacing: AppConstants.spacingS,
            runSpacing: AppConstants.spacingS,
            children: AppThemeType.values.map((themeType) {
              final isSelected = currentTheme == themeType;
              final themeColors = themeType.colorScheme;

              return InkWell(
                onTap: () => ref.read(themeProvider.notifier).theme = themeType,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withOpacity(0.1)
                        : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Color preview circles
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildColorCircle(themeColors.primary),
                          const SizedBox(width: 4),
                          _buildColorCircle(themeColors.secondary),
                          const SizedBox(width: 4),
                          _buildColorCircle(themeColors.success),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Text(
                        ThemeHelper.getThemeName(context, themeType),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? colors.primary
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
