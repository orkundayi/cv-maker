import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/subscription_service.dart';
import '../../domain/subscription.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Provider for SubscriptionService
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Provider for current user's subscription
final subscriptionProvider = StreamProvider<Subscription>((ref) {
  final authState = ref.watch(authStateProvider);
  final subscriptionService = ref.watch(subscriptionServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(Subscription.free('anonymous'));
      }
      return subscriptionService.watchSubscription(user.uid);
    },
    loading: () => Stream.value(Subscription.free('loading')),
    error: (_, _) => Stream.value(Subscription.free('error')),
  );
});

/// Provider for current subscription plan
final currentPlanProvider = Provider<SubscriptionPlan>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.maybeWhen(
    data: (sub) => sub.plan,
    orElse: () => SubscriptionPlan.free,
  );
});

/// Provider for checking if user has active subscription
final hasActiveSubscriptionProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.maybeWhen(
    data: (sub) => sub.plan != SubscriptionPlan.free && sub.isValid,
    orElse: () => false,
  );
});

/// Provider for checking if user can export PDF
final canExportPDFProvider = Provider<bool>((ref) {
  final plan = ref.watch(currentPlanProvider);
  return plan != SubscriptionPlan.free;
});

/// Provider for checking if user can export HTML
final canExportHTMLProvider = Provider<bool>((ref) {
  final plan = ref.watch(currentPlanProvider);
  return plan != SubscriptionPlan.free;
});

/// Provider for max CV count
final maxCVCountProvider = Provider<int>((ref) {
  final plan = ref.watch(currentPlanProvider);
  switch (plan) {
    case SubscriptionPlan.free:
      return 1;
    case SubscriptionPlan.pro:
      return 5;
    case SubscriptionPlan.premium:
      return -1; // Unlimited
  }
});

/// Subscription notifier for managing subscription actions
class SubscriptionNotifier extends StateNotifier<AsyncValue<Subscription>> {
  final SubscriptionService _subscriptionService;
  final String? _userId;

  SubscriptionNotifier(this._subscriptionService, this._userId)
    : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _loadSubscription();
    } else {
      state = AsyncValue.data(Subscription.free('anonymous'));
    }
  }

  Future<void> _loadSubscription() async {
    if (_userId == null) return;

    try {
      final subscription = await _subscriptionService.getCurrentSubscription(
        _userId,
      );
      state = AsyncValue.data(subscription);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadSubscription();
  }

  Future<bool> canCreateNewCV(int currentCVCount) async {
    if (_userId == null) return false;
    return _subscriptionService.canCreateNewCV(_userId, currentCVCount);
  }

  Future<bool> canUseTemplate(String templateId) async {
    if (_userId == null) return false;
    return _subscriptionService.canUseTemplate(_userId, templateId);
  }

  Future<bool> canExportPDF() async {
    if (_userId == null) return false;
    return _subscriptionService.canExportPDF(_userId);
  }
}

/// Provider for SubscriptionNotifier
final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<Subscription>>((
      ref,
    ) {
      final subscriptionService = ref.watch(subscriptionServiceProvider);
      final authState = ref.watch(authStateProvider);

      final userId = authState.maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );

      return SubscriptionNotifier(subscriptionService, userId);
    });
