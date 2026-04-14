import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_state.dart';
import 'package:unflappable/service/auth_service.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  // ── Field setters with real-time validation ──────────────────────────────

  void setEmail(String v) {
    final error = _validateEmail(v);
    state = state.copyWith(
      email: v,
      emailError: error,
      status: LoginStatus.idle,
    );
  }

  void setPassword(String v) {
    final error = _validatePassword(v);
    state = state.copyWith(
      password: v,
      passwordError: error,
      status: LoginStatus.idle,
    );
  }

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void clearError() =>
      state = state.copyWith(status: LoginStatus.idle, authErrorMessage: null);

  // ── Per-field validators ─────────────────────────────────────────────────

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);

    final hasErrors = emailError != null || passwordError != null;

    if (hasErrors) {
      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
        authErrorMessage:
            'Please fix the highlighted fields before continuing.',
        status: LoginStatus.validationError,
      );
      return;
    }

    state = state.copyWith(status: LoginStatus.loading);

    try {
      final response = await AuthService.login(
        fullName: _deriveNameFromEmail(state.email),
        email: state.email.trim(),
        password: state.password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(status: LoginStatus.success);
      } else {
        final message = _extractMessage(response) ??
            "Email or password didn't match. Please try again.";
        state = state.copyWith(
          status: LoginStatus.authError,
          authErrorMessage: message,
        );
      }
    } on DioException catch (e) {
      final message = e.response != null
          ? _extractMessage(e.response!) ??
              "Email or password didn't match. Please try again."
          : 'Unable to connect to the server. Please try again.';
      state = state.copyWith(
        status: LoginStatus.authError,
        authErrorMessage: message,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginStatus.authError,
        authErrorMessage: "Email or password didn't match. Please try again.",
      );
    }
  }

  String _deriveNameFromEmail(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'User';
    final segments = localPart.split(RegExp(r'[._\- ]+'));
    return segments
        .map((part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}')
        .where((part) => part.isNotEmpty)
        .join(' ');
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

  /// Convert exceptions from the auth repository into user-friendly messages.
  /// Expand this when you wire up the real API.
  String _mapErrorMessage(Object e) {
    if (e is DioException) {
      return e.response != null && e.response?.data is Map<String, dynamic>
          ? _extractMessage(e.response!) ??
              "Email or password didn't match. Please try again."
          : 'Unable to connect to the server. Please try again.';
    }
    return "Email or password didn't match. Please try again.";
  }
}
