import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/models/user.dart';
import 'package:unflappable/features/Auth/providers/user_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  /// Called after successful login
  /// Typically receives user data from API response
  void setUserInfo({
    required String id,
    required String email,
    required String name,
  }) {
    final user = User(
      id: id,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(status: UserStatus.authenticated, user: user);
  }

  /// Called on logout
  void clearUser() {
    state = state.copyWith(status: UserStatus.unauthenticated, clearUser: true);
  }

  /// Update any user field (called when user updates profile)
  void updateUserInfo({String? name, String? email}) {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(name: name, email: email);

    state = state.copyWith(user: updatedUser);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (_) => UserNotifier(),
);
