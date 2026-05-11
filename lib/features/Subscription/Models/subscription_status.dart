class SubscriptionEntitlements {
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

  const SubscriptionEntitlements({
    this.dailyMission = true,
    this.taskScorecard = true,
    this.resetsPerDay = 1,
    this.weeklyReview = true,
    this.basicStreaks = true,
    this.unlimitedResets = false,
    this.resetHistory = false,
    this.advancedTrends = false,
    this.premiumTemplates = false,
    this.deeperCoachingPrompts = false,
  });

  factory SubscriptionEntitlements.fromJson(Map<String, dynamic> json) {
    return SubscriptionEntitlements(
      dailyMission: json['dailyMission'] as bool? ?? true,
      taskScorecard: json['taskScorecard'] as bool? ?? true,
      resetsPerDay: (json['resetsPerDay'] as num?)?.toInt() ?? 1,
      weeklyReview: json['weeklyReview'] as bool? ?? true,
      basicStreaks: json['basicStreaks'] as bool? ?? true,
      unlimitedResets: json['unlimitedResets'] as bool? ?? false,
      resetHistory: json['resetHistory'] as bool? ?? false,
      advancedTrends: json['advancedTrends'] as bool? ?? false,
      premiumTemplates: json['premiumTemplates'] as bool? ?? false,
      deeperCoachingPrompts: json['deeperCoachingPrompts'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyMission': dailyMission,
    'taskScorecard': taskScorecard,
    'resetsPerDay': resetsPerDay,
    'weeklyReview': weeklyReview,
    'basicStreaks': basicStreaks,
    'unlimitedResets': unlimitedResets,
    'resetHistory': resetHistory,
    'advancedTrends': advancedTrends,
    'premiumTemplates': premiumTemplates,
    'deeperCoachingPrompts': deeperCoachingPrompts,
  };

  SubscriptionEntitlements copyWith({
    bool? dailyMission,
    bool? taskScorecard,
    int? resetsPerDay,
    bool? weeklyReview,
    bool? basicStreaks,
    bool? unlimitedResets,
    bool? resetHistory,
    bool? advancedTrends,
    bool? premiumTemplates,
    bool? deeperCoachingPrompts,
  }) =>
      SubscriptionEntitlements(
        dailyMission: dailyMission ?? this.dailyMission,
        taskScorecard: taskScorecard ?? this.taskScorecard,
        resetsPerDay: resetsPerDay ?? this.resetsPerDay,
        weeklyReview: weeklyReview ?? this.weeklyReview,
        basicStreaks: basicStreaks ?? this.basicStreaks,
        unlimitedResets: unlimitedResets ?? this.unlimitedResets,
        resetHistory: resetHistory ?? this.resetHistory,
        advancedTrends: advancedTrends ?? this.advancedTrends,
        premiumTemplates: premiumTemplates ?? this.premiumTemplates,
        deeperCoachingPrompts:
            deeperCoachingPrompts ?? this.deeperCoachingPrompts,
      );
}

class SubscriptionStatus {
  final String plan;
  final bool isPro;
  final DateTime? proExpiresAt;
  final String? proProductId;
  final SubscriptionEntitlements entitlements;

  const SubscriptionStatus({
    required this.plan,
    required this.isPro,
    this.proExpiresAt,
    this.proProductId,
    required this.entitlements,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final entitlementsJson = json['entitlements'] as Map<String, dynamic>? ?? {};

    return SubscriptionStatus(
      plan: (json['plan'] ?? '').toString(),
      isPro: json['isPro'] as bool? ?? false,
      proExpiresAt: json['proExpiresAt'] is String
          ? DateTime.tryParse(json['proExpiresAt'])
          : null,
      proProductId: json['proProductId'] as String?,
      entitlements: SubscriptionEntitlements.fromJson(
        Map<String, dynamic>.from(entitlementsJson),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'plan': plan,
    'isPro': isPro,
    if (proExpiresAt != null) 'proExpiresAt': proExpiresAt?.toIso8601String(),
    if (proProductId != null) 'proProductId': proProductId,
    'entitlements': entitlements.toJson(),
  };

  SubscriptionStatus copyWith({
    String? plan,
    bool? isPro,
    DateTime? proExpiresAt,
    String? proProductId,
    SubscriptionEntitlements? entitlements,
  }) =>
      SubscriptionStatus(
        plan: plan ?? this.plan,
        isPro: isPro ?? this.isPro,
        proExpiresAt: proExpiresAt ?? this.proExpiresAt,
        proProductId: proProductId ?? this.proProductId,
        entitlements: entitlements ?? this.entitlements,
      );
}
