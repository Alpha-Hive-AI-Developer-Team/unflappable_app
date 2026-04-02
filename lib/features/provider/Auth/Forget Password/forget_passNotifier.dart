import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/Forget%20Password/forget_passState.dart';

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(const ForgotPasswordState());

  void setEmail(String v) => state = state.copyWith(email: v);

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    // TODO: call auth repository
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }
}
