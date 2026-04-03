import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  void setEmail(String v) =>
      state = state.copyWith(email: v, status: LoginStatus.idle);
  void setPassword(String v) =>
      state = state.copyWith(password: v, status: LoginStatus.idle);
  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  void clearError() => state = state.copyWith(status: LoginStatus.idle);

  Future<void> submit() async {
    // Validate email and password
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Both email and password are required',
      );
      return;
    }

    // Validate email format
    if (!_isValidEmail(state.email)) {
      state = state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Please enter a valid email',
      );
      return;
    }

    state = state.copyWith(status: LoginStatus.loading);
    // TODO: call auth repository
    await Future.delayed(const Duration(seconds: 1));

    // On success, navigate to home
    state = state.copyWith(status: LoginStatus.success);
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}
