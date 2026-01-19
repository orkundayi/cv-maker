import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../features/subscription/domain/subscription.dart';

/// Helper class to get localized subscription plan strings
class SubscriptionHelper {
  /// Get localized plan display name
  static String getDisplayName(BuildContext context, SubscriptionPlan plan) {
    final l10n = AppLocalizations.of(context)!;

    switch (plan) {
      case SubscriptionPlan.free:
        return l10n.planFree;
      case SubscriptionPlan.pro:
        return l10n.planPro;
      case SubscriptionPlan.premium:
        return l10n.planPremium;
    }
  }

  /// Get localized plan description
  static String getDescription(BuildContext context, SubscriptionPlan plan) {
    final l10n = AppLocalizations.of(context)!;

    switch (plan) {
      case SubscriptionPlan.free:
        return l10n.subscriptionFreeDesc;
      case SubscriptionPlan.pro:
        return l10n.subscriptionProDesc;
      case SubscriptionPlan.premium:
        return l10n.subscriptionPremiumDesc;
    }
  }

  /// Get localized plan features
  static List<String> getFeatures(BuildContext context, SubscriptionPlan plan) {
    final l10n = AppLocalizations.of(context)!;

    switch (plan) {
      case SubscriptionPlan.free:
        return [
          l10n.feature1CV,
          l10n.featureBasicTemplates,
          l10n.featureCloudStorage,
          l10n.featurePreview,
        ];
      case SubscriptionPlan.pro:
        return [
          l10n.feature5CV,
          l10n.featureAllTemplates,
          l10n.featurePdfExport,
          l10n.featureHtmlExport,
          l10n.featureCloudStorage,
          l10n.featurePrioritySupport,
        ];
      case SubscriptionPlan.premium:
        return [
          l10n.featureUnlimitedCV,
          l10n.featureAllTemplates,
          l10n.featurePdfExport,
          l10n.featureHtmlExport,
          l10n.featureJsonExport,
          l10n.featureCloudStorage,
          l10n.featureCustomTemplates,
          l10n.featurePrioritySupport,
        ];
    }
  }
}
