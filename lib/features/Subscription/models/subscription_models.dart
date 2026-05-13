class SubscriptionPlanFeatureItem {
  const SubscriptionPlanFeatureItem({
    required this.label,
    required this.included,
    this.subtitle,
  });

  final String label;
  final bool included;
  final String? subtitle;

  factory SubscriptionPlanFeatureItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanFeatureItem(
      label: json['label'] as String? ?? '',
      included: json['included'] as bool? ?? false,
      subtitle: json['subtitle'] as String?,
    );
  }
}

class ProProductIds {
  const ProProductIds({required this.monthly, required this.yearly});

  /// SKUs configured in App Store Connect (Unflappable Pro group).
  static const String appStoreConnectMonthly =
      'com.alphahiveai.unflappable.pro.monthly';
  static const String appStoreConnectYearly =
      'com.alphahiveai.unflappable.pro.yearly';

  /// Older API values that do not match App Store Connect.
  static const String legacyApiMonthly = 'com.unflappable.pro.monthly';
  static const String legacyApiYearly = 'com.unflappable.pro.yearly';

  final String monthly;
  final String yearly;

  factory ProProductIds.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProProductIds(monthly: '', yearly: '');
    }
    return ProProductIds(
      monthly: json['monthly'] as String? ?? '',
      yearly: json['yearly'] as String? ?? '',
    );
  }

  /// Maps legacy backend IDs (and empty fallbacks) to App Store Connect SKUs
  /// so `queryProductDetails` succeeds on iOS / macOS.
  ProProductIds forAppleStoreKit() {
    return ProProductIds(
      monthly: _appleSku(
        monthly,
        legacy: legacyApiMonthly,
        canonical: appStoreConnectMonthly,
      ),
      yearly: _appleSku(
        yearly,
        legacy: legacyApiYearly,
        canonical: appStoreConnectYearly,
      ),
    );
  }

  /// From `GET /api/subscription/status` [`proProductId`] or similar.
  static bool isYearlyProductId(String? productId) {
    if (productId == null || productId.trim().isEmpty) return false;
    return productId.toLowerCase().contains('yearly');
  }

  static String _appleSku(
    String fromApi, {
    required String legacy,
    required String canonical,
  }) {
    if (fromApi.isEmpty || fromApi == legacy || fromApi == canonical) {
      return canonical;
    }
    return fromApi;
  }
}

class FreePlanPayload {
  const FreePlanPayload({
    required this.name,
    this.price,
    required this.features,
  });

  final String name;
  final String? price;
  final List<SubscriptionPlanFeatureItem> features;

  factory FreePlanPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['features'];
    final features = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (e) => SubscriptionPlanFeatureItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : <SubscriptionPlanFeatureItem>[];
    return FreePlanPayload(
      name: json['name'] as String? ?? 'Free',
      price: json['price'] as String?,
      features: features,
    );
  }
}

class ProPlanPayload {
  const ProPlanPayload({
    required this.name,
    this.monthlyPrice,
    this.yearlyPrice,
    this.yearlyMonthlyEquivalent,
    required this.productIds,
    required this.features,
  });

  final String name;
  final String? monthlyPrice;
  final String? yearlyPrice;
  final String? yearlyMonthlyEquivalent;
  final ProProductIds productIds;
  final List<SubscriptionPlanFeatureItem> features;

  factory ProPlanPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['features'];
    final features = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (e) => SubscriptionPlanFeatureItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : <SubscriptionPlanFeatureItem>[];
    return ProPlanPayload(
      name: json['name'] as String? ?? 'Pro',
      monthlyPrice: json['monthlyPrice'] as String?,
      yearlyPrice: json['yearlyPrice'] as String?,
      yearlyMonthlyEquivalent: json['yearlyMonthlyEquivalent'] as String?,
      productIds: ProProductIds.fromJson(
        json['productIds'] is Map<String, dynamic>
            ? json['productIds'] as Map<String, dynamic>
            : null,
      ),
      features: features,
    );
  }
}

class SubscriptionPlansPayload {
  const SubscriptionPlansPayload({required this.free, required this.pro});

  final FreePlanPayload free;
  final ProPlanPayload pro;

  factory SubscriptionPlansPayload.fromJson(Map<String, dynamic> json) {
    final freeMap = json['free'];
    final proMap = json['pro'];
    return SubscriptionPlansPayload(
      free: freeMap is Map<String, dynamic>
          ? FreePlanPayload.fromJson(freeMap)
          : const FreePlanPayload(name: 'Free', features: []),
      pro: proMap is Map<String, dynamic>
          ? ProPlanPayload.fromJson(proMap)
          : ProPlanPayload(
              name: 'Pro',
              productIds: const ProProductIds(monthly: '', yearly: ''),
              features: const [],
            ),
    );
  }
}

class SubscriptionEntitlements {
  const SubscriptionEntitlements({
    required this.dailyMission,
    required this.taskScorecard,
    required this.resetsPerDay,
    required this.weeklyReview,
    required this.basicStreaks,
    required this.unlimitedResets,
    required this.resetHistory,
    required this.advancedTrends,
    required this.premiumTemplates,
    required this.deeperCoachingPrompts,
  });

  final bool dailyMission;
  final bool taskScorecard;
  final int resetsPerDay;
  final bool weeklyReview;
  final bool basicStreaks;
  final bool unlimitedResets;
  final bool resetHistory;
  final bool advancedTrends;
  final bool premiumTemplates;
  final bool deeperCoachingPrompts;

  factory SubscriptionEntitlements.fromJson(Map<String, dynamic> json) {
    return SubscriptionEntitlements(
      dailyMission: json['dailyMission'] as bool? ?? false,
      taskScorecard: json['taskScorecard'] as bool? ?? false,
      resetsPerDay: (json['resetsPerDay'] as num?)?.toInt() ?? 0,
      weeklyReview: json['weeklyReview'] as bool? ?? false,
      basicStreaks: json['basicStreaks'] as bool? ?? false,
      unlimitedResets: json['unlimitedResets'] as bool? ?? false,
      resetHistory: json['resetHistory'] as bool? ?? false,
      advancedTrends: json['advancedTrends'] as bool? ?? false,
      premiumTemplates: json['premiumTemplates'] as bool? ?? false,
      deeperCoachingPrompts: json['deeperCoachingPrompts'] as bool? ?? false,
    );
  }
}

class SubscriptionStatusPayload {
  const SubscriptionStatusPayload({
    required this.plan,
    required this.isPro,
    this.proExpiresAt,
    this.proProductId,
    required this.entitlements,
  });

  final String plan;
  final bool isPro;
  final DateTime? proExpiresAt;
  final String? proProductId;
  final SubscriptionEntitlements entitlements;

  factory SubscriptionStatusPayload.fromJson(Map<String, dynamic> json) {
    final ent = json['entitlements'];
    return SubscriptionStatusPayload(
      plan: json['plan'] as String? ?? 'free',
      isPro: json['isPro'] as bool? ?? false,
      proExpiresAt: _parseDate(json['proExpiresAt']),
      proProductId: json['proProductId'] as String?,
      entitlements: ent is Map<String, dynamic>
          ? SubscriptionEntitlements.fromJson(ent)
          : const SubscriptionEntitlements(
              dailyMission: false,
              taskScorecard: false,
              resetsPerDay: 0,
              weeklyReview: false,
              basicStreaks: false,
              unlimitedResets: false,
              resetHistory: false,
              advancedTrends: false,
              premiumTemplates: false,
              deeperCoachingPrompts: false,
            ),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
