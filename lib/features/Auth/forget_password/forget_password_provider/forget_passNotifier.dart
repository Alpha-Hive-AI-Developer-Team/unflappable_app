import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/forget_password/forget_password_provider/forget_passState.dart';

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(const ForgotPasswordState());

  void setEmail(String v) {
    final error = _validateEmail(v);
    state = state.copyWith(
      email: v,
      emailError: error,
      status: ForgotPasswordStatus.idle,
    );
  }

  void clearError() => state = state.copyWith(
    status: ForgotPasswordStatus.idle,
    authErrorMessage: null,
  );

  Future<bool> submit() async {
    final emailError = _validateEmail(state.email);
    final hasErrors = emailError != null;

    if (hasErrors) {
      state = state.copyWith(
        emailError: emailError,
        authErrorMessage:
            'Please fix the highlighted fields before continuing.',
        status: ForgotPasswordStatus.validationError,
      );
      return false;
    }

    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      isLoading: true,
    );

    try {
      // TODO: replace with real auth repository call
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        isLoading: false,
        status: ForgotPasswordStatus.success,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: ForgotPasswordStatus.authError,
        authErrorMessage: 'Unable to send reset link. Please try again.',
      );
      return false;
    }
  }

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
