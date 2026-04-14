import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/forget_password/forget_password_provider/forget_passState.dart';
import 'package:unflappable/service/auth_service.dart';

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
      final response = await AuthService.forgotPassword(
        email: state.email.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          status: ForgotPasswordStatus.success,
        );
        return true;
      }

      final errorMessage = _extractMessage(response) ??
          'Unable to send reset link. Please try again.';
      state = state.copyWith(
        isLoading: false,
        status: ForgotPasswordStatus.authError,
        authErrorMessage: errorMessage,
      );
      return false;
    } on DioException catch (e) {
      final message = e.response != null
          ? _extractMessage(e.response!) ??
              'Unable to send reset link. Please try again.'
          : 'Unable to connect to the server. Please try again.';
      state = state.copyWith(
        isLoading: false,
        status: ForgotPasswordStatus.authError,
        authErrorMessage: message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: ForgotPasswordStatus.authError,
        authErrorMessage: 'Unable to send reset link. Please try again.',
      );
      return false;
    }
  }

  String? _extractMessage(Response response) {
    if (response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      return body['message']?.toString() ??
          body['error']?.toString() ??
          body['errors']?.toString();
    }
    return null;
  }

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
