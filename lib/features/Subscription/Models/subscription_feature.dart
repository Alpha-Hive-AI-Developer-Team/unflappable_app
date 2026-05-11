class SubscriptionFeature {
  final String label;
  final bool included;
  final String? subtitle;

  const SubscriptionFeature({
    required this.label,
    required this.included,
    this.subtitle,
  });

  factory SubscriptionFeature.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeature(
      label: (json['label'] ?? '').toString(),
      included: json['included'] as bool? ?? false,
      subtitle: json['subtitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'included': included,
    if (subtitle != null) 'subtitle': subtitle,
  };

  SubscriptionFeature copyWith({
    String? label,
    bool? included,
    String? subtitle,
  }) =>
      SubscriptionFeature(
        label: label ?? this.label,
        included: included ?? this.included,
        subtitle: subtitle ?? this.subtitle,
      );
}
