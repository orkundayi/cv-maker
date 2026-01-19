import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/subscription_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/subscription.dart';
import '../pages/pricing_page.dart';

/// Widget to prompt users to upgrade their subscription
class UpgradePrompt extends StatelessWidget {
  final String feature;
  final String? message;
  final SubscriptionPlan requiredPlan;

  const UpgradePrompt({
    super.key,
    required this.feature,
    this.message,
    this.requiredPlan = SubscriptionPlan.pro,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final planName = SubscriptionHelper.getDisplayName(context, requiredPlan);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsFill.lock,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            message ?? l10n.featureRequiresPlan(planName),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            l10n.upgradeForMore,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingL),
          ElevatedButton.icon(
            onPressed: () => _showPricingPage(context),
            icon: const Icon(PhosphorIconsRegular.arrowUp),
            label: Text(l10n.viewPlansButton),
          ),
        ],
      ),
    );
  }

  void _showPricingPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PricingPage()),
    );
  }
}

/// Small upgrade banner for inline use
class UpgradeBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onUpgrade;

  const UpgradeBanner({super.key, required this.message, this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.star, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade900,
              ),
            ),
          ),
          TextButton(
            onPressed: onUpgrade ?? () => _showPricingPage(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.upgradeButton,
              style: TextStyle(
                color: Colors.amber.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPricingPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PricingPage()),
    );
  }
}

/// Feature lock overlay
class FeatureLockOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final String? lockedMessage;

  const FeatureLockOverlay({
    super.key,
    required this.child,
    required this.isLocked,
    this.lockedMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Opacity(opacity: 0.5, child: IgnorePointer(child: child)),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showUpgradeDialog(context),
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsFill.lock,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lockedMessage ?? l10n.proFeature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(PhosphorIconsFill.lock),
            const SizedBox(width: 8),
            Text(l10n.premiumFeature),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UpgradePrompt(
              feature: 'premium_feature',
              message: l10n.upgradeToUse,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

/// Subscription badge widget
class SubscriptionBadge extends ConsumerWidget {
  const SubscriptionBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // This would typically come from a provider
    // For now, we'll show a simple badge

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsFill.star, size: 14, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            'Pro',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.amber.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
