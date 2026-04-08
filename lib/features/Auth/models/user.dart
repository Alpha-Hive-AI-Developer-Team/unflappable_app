class User {
  final String id;
  final String email;
  final String name;
  final bool isPro;
  final DateTime createdAt;
  final DateTime? proSubscribedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.isPro = false,
    required this.createdAt,
    this.proSubscribedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPro,
    DateTime? createdAt,
    DateTime? proSubscribedAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        isPro: isPro ?? this.isPro,
        createdAt: createdAt ?? this.createdAt,
        proSubscribedAt: proSubscribedAt ?? this.proSubscribedAt,
      );
}
