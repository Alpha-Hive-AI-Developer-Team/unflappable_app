import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_state.dart';

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(const SignUpState());

  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    // TODO: call auth repository
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }
}
