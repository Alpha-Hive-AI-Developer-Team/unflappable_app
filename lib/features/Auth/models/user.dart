class User {
  final String id;
  final String email;
  final String name;
  final bool isPro;
  final DateTime createdAt;
  final DateTime? proSubscribedAt;
  /// From `GET /api/subscription/status` when available (e.g. monthly vs yearly SKU).
  final String? proProductId;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.isPro = false,
    required this.createdAt,
    this.proSubscribedAt,
    this.proProductId,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPro,
    DateTime? createdAt,
    DateTime? proSubscribedAt,
    String? proProductId,
    bool clearProProductId = false,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        isPro: isPro ?? this.isPro,
        createdAt: createdAt ?? this.createdAt,
        proSubscribedAt: proSubscribedAt ?? this.proSubscribedAt,
        proProductId: clearProProductId
            ? null
            : (proProductId ?? this.proProductId),
      );
}
