class User {
  final String id;
  final String email;
  final String name;
  final bool isPro;
  final DateTime createdAt;
  final DateTime? proSubscribedAt;
  /// From `GET /api/subscription/status` when available (e.g. monthly vs yearly SKU).
  final String? proProductId;
  /// UA-11 / UN-43: from login/Apple/verify-email/account responses.
  /// Defaults to true (fail-open) so a missing field never traps a user in
  /// an onboarding loop — only an explicit `false` routes to onboarding.
  final bool onboardingCompleted;
  /// 'password' / 'apple' / etc, as returned by the backend.
  final String? authProvider;
  /// Whether the account has a password set (false for Apple-only accounts
  /// that haven't set one yet). Defaults to true (fail-open) for the same
  /// reason as [onboardingCompleted].
  final bool hasPassword;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.isPro = false,
    required this.createdAt,
    this.proSubscribedAt,
    this.proProductId,
    this.onboardingCompleted = true,
    this.authProvider,
    this.hasPassword = true,
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
    bool? onboardingCompleted,
    String? authProvider,
    bool? hasPassword,
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
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        authProvider: authProvider ?? this.authProvider,
        hasPassword: hasPassword ?? this.hasPassword,
      );
}
