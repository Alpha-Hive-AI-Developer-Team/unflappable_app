import 'subscription_feature.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final double? price;
  final String? monthlyPrice;
  final String? yearlyPrice;
  final String? yearlyMonthlyEquivalent;
  final Map<String, String>? productIds;
  final List<SubscriptionFeature> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.price,
    this.monthlyPrice,
    this.yearlyPrice,
    this.yearlyMonthlyEquivalent,
    this.productIds,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(
    String planId,
    Map<String, dynamic> json,
  ) {
    final featuresData = json['features'] as List? ?? [];
    final features = featuresData
        .whereType<Map<String, dynamic>>()
        .map((f) => SubscriptionFeature.fromJson(f))
        .toList();

    final productIdsData = json['productIds'];
    Map<String, String>? productIds;
    if (productIdsData is Map) {
      productIds = Map<String, String>.from(
        productIdsData.cast<String, dynamic>().map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }

    return SubscriptionPlan(
      id: planId,
      name: (json['name'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble(),
      monthlyPrice: json['monthlyPrice'] as String?,
      yearlyPrice: json['yearlyPrice'] as String?,
      yearlyMonthlyEquivalent: json['yearlyMonthlyEquivalent'] as String?,
      productIds: productIds,
      features: features,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (price != null) 'price': price,
    if (monthlyPrice != null) 'monthlyPrice': monthlyPrice,
    if (yearlyPrice != null) 'yearlyPrice': yearlyPrice,
    if (yearlyMonthlyEquivalent != null)
      'yearlyMonthlyEquivalent': yearlyMonthlyEquivalent,
    if (productIds != null) 'productIds': productIds,
    'features': features.map((f) => f.toJson()).toList(),
  };

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    double? price,
    String? monthlyPrice,
    String? yearlyPrice,
    String? yearlyMonthlyEquivalent,
    Map<String, String>? productIds,
    List<SubscriptionFeature>? features,
  }) =>
      SubscriptionPlan(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        monthlyPrice: monthlyPrice ?? this.monthlyPrice,
        yearlyPrice: yearlyPrice ?? this.yearlyPrice,
        yearlyMonthlyEquivalent:
            yearlyMonthlyEquivalent ?? this.yearlyMonthlyEquivalent,
        productIds: productIds ?? this.productIds,
        features: features ?? this.features,
      );
}
