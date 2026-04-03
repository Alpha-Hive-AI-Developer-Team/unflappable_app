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
    state = state.copyWith(status: LoginStatus.loading);
    // TODO: call auth repository
    await Future.delayed(const Duration(seconds: 1));
    // Simulate error for demo — replace with real logic
    state = state.copyWith(status: LoginStatus.error);
  }
}
