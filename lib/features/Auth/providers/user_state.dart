import 'package:unflappable/features/Auth/models/user.dart';

enum UserStatus { initial, loading, authenticated, unauthenticated, error }

class UserState {
  final UserStatus status;
  final User? user;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated =>
      status == UserStatus.authenticated && user != null;
  bool get isPro => user?.isPro ?? false;
  String get userName => user?.name ?? '';
  String get userEmail => user?.email ?? '';
  bool get onboardingCompleted => user?.onboardingCompleted ?? true;
  bool get hasPassword => user?.hasPassword ?? true;
  String? get authProvider => user?.authProvider;

  UserState copyWith({
    UserStatus? status,
    User? user,
    String? errorMessage,
    bool clearUser = false,
  }) => UserState(
    status: status ?? this.status,
    user: clearUser ? null : (user ?? this.user),
    errorMessage: errorMessage,
  );
}
