/// Subscription plan types
enum SubscriptionPlan {
  free,
  pro,
  premium;

  /// Monthly price in TRY
  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.pro:
        return 49;
      case SubscriptionPlan.premium:
        return 99;
    }
  }

  /// Maximum number of CVs allowed (-1 for unlimited)
  int get maxCVs {
    switch (this) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.pro:
        return 5;
      case SubscriptionPlan.premium:
        return -1; // Unlimited
    }
  }

  /// Whether PDF export is allowed
  bool get canExportPDF {
    switch (this) {
      case SubscriptionPlan.free:
        return false;
      case SubscriptionPlan.pro:
      case SubscriptionPlan.premium:
        return true;
    }
  }
}

/// Subscription model
class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? paymentId;
  final DateTime createdAt;

  const Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.paymentId,
    required this.createdAt,
  });

  /// Check if subscription is expired
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Check if subscription is valid (active and not expired)
  bool get isValid => isActive && !isExpired;

  /// Get remaining days
  int? get remainingDays {
    if (endDate == null) return null;
    final diff = endDate!.difference(DateTime.now());
    return diff.inDays;
  }

  factory Subscription.free(String userId) {
    return Subscription(
      id: 'free',
      userId: userId,
      plan: SubscriptionPlan.free,
      startDate: DateTime.now(),
      endDate: null,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == (json['plan'] as String?),
        orElse: () => SubscriptionPlan.free,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      paymentId: json['paymentId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? paymentId,
    DateTime? createdAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
