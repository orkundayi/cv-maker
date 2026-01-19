import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../features/subscription/domain/subscription.dart';

/// Helper class to get localized feature gate messages
class FeatureGateHelper {
  /// Get upgrade message for a feature
  static String getUpgradeMessage(
    BuildContext context,
    String feature,
    SubscriptionPlan currentPlan,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final neededPlan = _getNeededPlanForFeature(feature);

    if (neededPlan == null) {
      return l10n.featureNotAvailable;
    }

    if (currentPlan == SubscriptionPlan.free) {
      if (neededPlan == SubscriptionPlan.pro) {
        return l10n.upgradeToPro;
      } else {
        return l10n.upgradeToPremium;
      }
    } else if (currentPlan == SubscriptionPlan.pro) {
      return l10n.upgradeToPremium;
    }

    return l10n.featureIncluded;
  }

  static SubscriptionPlan? _getNeededPlanForFeature(String feature) {
    switch (feature) {
      case 'pdf_export':
      case 'html_export':
      case 'premium_templates':
      case 'more_cvs':
        return SubscriptionPlan.pro;
      case 'json_export':
      case 'custom_templates':
      case 'unlimited_cvs':
        return SubscriptionPlan.premium;
      default:
        return null;
    }
  }

  /// Get list of locked features for a plan (localized)
  static List<String> getLockedFeatures(
    BuildContext context,
    SubscriptionPlan plan,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (plan) {
      case SubscriptionPlan.free:
        return [
          l10n.lockedPdfExport,
          l10n.lockedHtmlExport,
          l10n.lockedPremiumTemplates,
          l10n.lockedMultipleCVs,
          l10n.lockedJsonExport,
          l10n.lockedCustomTemplates,
        ];
      case SubscriptionPlan.pro:
        return [
          l10n.lockedUnlimitedCV,
          l10n.lockedJsonExport,
          l10n.lockedCustomTemplates,
        ];
      case SubscriptionPlan.premium:
        return [];
    }
  }

  /// Get remaining CV count message (localized)
  static String getRemainingCVMessage(
    BuildContext context,
    SubscriptionPlan plan,
    int currentCount,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // Get max count from plan
    final maxCount = plan.maxCVs;

    if (maxCount == -1) {
      return l10n.unlimitedCVMessage;
    }

    final remaining = maxCount - currentCount;

    if (remaining <= 0) {
      return l10n.cvLimitReached;
    }

    return l10n.remainingCVMessage(remaining.toString());
  }
}
