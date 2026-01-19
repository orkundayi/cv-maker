import 'subscription.dart';

/// Feature gating based on subscription plan
class FeatureGate {
  /// Maximum number of CVs allowed for each plan
  static int maxCVCount(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.pro:
        return 5;
      case SubscriptionPlan.premium:
        return -1; // Unlimited
    }
  }

  /// Check if user can create a new CV
  static bool canCreateNewCV(SubscriptionPlan plan, int currentCVCount) {
    final maxCount = maxCVCount(plan);
    if (maxCount == -1) return true; // Unlimited
    return currentCVCount < maxCount;
  }

  /// Available template IDs for each plan
  static List<String> availableTemplates(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return ['minimal', 'basic'];
      case SubscriptionPlan.pro:
        return ['minimal', 'basic', 'modern', 'professional', 'creative'];
      case SubscriptionPlan.premium:
        return [
          'minimal',
          'basic',
          'modern',
          'professional',
          'creative',
          'executive',
          'designer',
          'developer',
          'custom',
        ];
    }
  }

  /// Check if template is available for the plan
  static bool canUseTemplate(SubscriptionPlan plan, String templateId) {
    return availableTemplates(plan).contains(templateId);
  }

  /// Check if PDF export is available
  static bool canExportPDF(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return false;
      case SubscriptionPlan.pro:
      case SubscriptionPlan.premium:
        return true;
    }
  }

  /// Check if HTML export is available
  static bool canExportHTML(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return false;
      case SubscriptionPlan.pro:
      case SubscriptionPlan.premium:
        return true;
    }
  }

  /// Check if JSON export is available
  static bool canExportJSON(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
      case SubscriptionPlan.pro:
        return false;
      case SubscriptionPlan.premium:
        return true;
    }
  }

  /// Check if custom templates are available
  static bool canUseCustomTemplates(SubscriptionPlan plan) {
    return plan == SubscriptionPlan.premium;
  }
}
