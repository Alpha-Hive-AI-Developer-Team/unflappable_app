class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
}
