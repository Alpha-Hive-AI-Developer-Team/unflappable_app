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
    required bool isPro,
  }) {
    final user = User(
      id: id,
      email: email,
      name: name,
      isPro: isPro,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(status: UserStatus.authenticated, user: user);
  }

  Future<void> updateProStatus(bool isPro) async {
    if (state.user == null) return;

    try {
      state = state.copyWith(status: UserStatus.loading);

      // TODO: Call API to update pro status
      // await ref.read(authRepositoryProvider).updateProStatus(isPro);
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedUser = state.user!.copyWith(
        isPro: isPro,
        proSubscribedAt: isPro ? DateTime.now() : null,
      );

      state = state.copyWith(
        status: UserStatus.authenticated,
        user: updatedUser,
      );
    } catch (e) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      );
    }
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
