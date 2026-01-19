import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/subscription.dart';

/// Service for managing subscriptions
class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get subscription document reference
  DocumentReference<Map<String, dynamic>> _getSubscriptionRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  /// Get current subscription for a user
  Future<Subscription> getCurrentSubscription(String userId) async {
    try {
      final doc = await _getSubscriptionRef(userId).get();

      if (!doc.exists || doc.data() == null) {
        return Subscription.free(userId);
      }

      final data = doc.data()!;
      final subscriptionData = data['subscription'] as Map<String, dynamic>?;

      if (subscriptionData == null) {
        return Subscription.free(userId);
      }

      final subscription = Subscription.fromJson({
        ...subscriptionData,
        'userId': userId,
      });

      // If subscription is expired, return free plan
      if (subscription.isExpired) {
        return Subscription.free(userId);
      }

      return subscription;
    } catch (e) {
      // Return free plan on error
      return Subscription.free(userId);
    }
  }

  /// Watch subscription changes
  Stream<Subscription> watchSubscription(String userId) {
    return _getSubscriptionRef(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return Subscription.free(userId);
      }

      final data = doc.data()!;
      final subscriptionData = data['subscription'] as Map<String, dynamic>?;

      if (subscriptionData == null) {
        return Subscription.free(userId);
      }

      final subscription = Subscription.fromJson({
        ...subscriptionData,
        'userId': userId,
      });

      if (subscription.isExpired) {
        return Subscription.free(userId);
      }

      return subscription;
    });
  }

  /// Create or update subscription (called after payment)
  Future<void> updateSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required String paymentId,
    int durationMonths = 1,
  }) async {
    try {
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + durationMonths, now.day);

      final subscription = Subscription(
        id: 'sub_${now.millisecondsSinceEpoch}',
        userId: userId,
        plan: plan,
        startDate: now,
        endDate: endDate,
        isActive: true,
        paymentId: paymentId,
        createdAt: now,
      );

      await _getSubscriptionRef(
        userId,
      ).update({'subscription': subscription.toJson()});
    } catch (e) {
      throw Exception('Abonelik güncellenemedi: $e');
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription(String userId) async {
    try {
      await _getSubscriptionRef(
        userId,
      ).update({'subscription': Subscription.free(userId).toJson()});
    } catch (e) {
      throw Exception('Abonelik iptal edilemedi: $e');
    }
  }

  /// Check if user can create new CV based on subscription
  Future<bool> canCreateNewCV(String userId, int currentCVCount) async {
    final subscription = await getCurrentSubscription(userId);

    switch (subscription.plan) {
      case SubscriptionPlan.free:
        return currentCVCount < 1;
      case SubscriptionPlan.pro:
        return currentCVCount < 5;
      case SubscriptionPlan.premium:
        return true; // Unlimited
    }
  }

  /// Check if user can use a specific template
  Future<bool> canUseTemplate(String userId, String templateId) async {
    final subscription = await getCurrentSubscription(userId);

    // Free templates available for all
    const freeTemplates = ['minimal', 'basic'];
    if (freeTemplates.contains(templateId)) {
      return true;
    }

    // Pro templates
    const proTemplates = ['modern', 'professional', 'creative'];
    if (proTemplates.contains(templateId)) {
      return subscription.plan == SubscriptionPlan.pro ||
          subscription.plan == SubscriptionPlan.premium;
    }

    // Premium templates
    return subscription.plan == SubscriptionPlan.premium;
  }

  /// Check if user can export PDF
  Future<bool> canExportPDF(String userId) async {
    final subscription = await getCurrentSubscription(userId);
    return subscription.plan != SubscriptionPlan.free;
  }

  /// Check if user can export HTML
  Future<bool> canExportHTML(String userId) async {
    final subscription = await getCurrentSubscription(userId);
    return subscription.plan != SubscriptionPlan.free;
  }

  /// Initialize free subscription for new user
  Future<void> initializeFreeSubscription(String userId) async {
    try {
      await _getSubscriptionRef(userId).set({
        'subscription': Subscription.free(userId).toJson(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore error for new users
    }
  }
}
