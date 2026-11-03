import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_state.dart';
import 'package:unflappable/service/auth_service.dart';

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(const SignUpState());

  // ── Field setters with real-time validation ──────────────────────────────

  void setFullName(String v) {
    final error = _validateFullName(v);
    state = state.copyWith(
      fullName: v,
      fullNameError: error, // null when valid, message when invalid
      status: SignUpStatus.idle,
      authErrorMessage: null,
    );
  }

  void setEmail(String v) {
    final error = _validateEmail(v);
    state = state.copyWith(
      email: v,
      emailError: error,
      status: SignUpStatus.idle,
      authErrorMessage: null,
    );
  }

  void setPassword(String v) {
    final error = _validatePassword(v);
    state = state.copyWith(
      password: v,
      passwordError: error,
      confirmPasswordError: state.confirmPassword.isEmpty
          ? state.confirmPasswordError
          : (v == state.confirmPassword ? null : 'Passwords do not match'),
      status: SignUpStatus.idle,
      authErrorMessage: null,
    );
  }

  void setConfirmPassword(String v) {
    final error = _validateConfirmPassword(v);
    state = state.copyWith(
      confirmPassword: v,
      confirmPasswordError: error,
      status: SignUpStatus.idle,
      authErrorMessage: null,
    );
  }

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  // UA-67: independent from toggleObscure so the Password and Confirm
  // Password eye icons no longer control the same flag.
  void toggleObscureConfirm() => state = state.copyWith(
    obscureConfirmPassword: !state.obscureConfirmPassword,
  );

  void clearError() =>
      state = state.copyWith(status: SignUpStatus.idle, authErrorMessage: null);

  // ── Per-field validators (shared by real-time + submit) ──────────────────

  // UA-12: input formatters already block disallowed characters at the
  // field, but validate again here too — paste, autofill, or any other
  // bypass of the formatter shouldn't be able to reach the backend.
  static final _fullNamePattern = RegExp(r"^[\p{L} '\-]+$", unicode: true);

  String? _validateFullName(String v) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) return 'Full name is required';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    if (trimmed.length > 80) return 'Name must be 80 characters or fewer';
    if (!_fullNamePattern.hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  String? _validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String v) {
    if (v.isEmpty) return 'Confirm password is required';
    if (v != state.password) return 'Passwords do not match';
    return null;
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  /// Runs full validation, shows the error overlay on any failure,
  /// then calls the auth API on success.
  Future<void> submit(BuildContext context) async {
    final fullNameError = _validateFullName(state.fullName);
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);
    final confirmPasswordError = _validateConfirmPassword(
      state.confirmPassword,
    );

    final hasErrors =
        fullNameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null;

    if (hasErrors) {
      // Write all field errors and show the overlay
      state = state.copyWith(
        fullNameError: fullNameError,
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        authErrorMessage:
            'Please fix the highlighted fields before continuing.',
        status: SignUpStatus.validationError,
      );
      return;
    }

    // ── Happy path ─────────────────────────────────────────────────────────
    state = state.copyWith(status: SignUpStatus.loading);

    try {
      final response = await AuthService.signUp(
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // UA-30: never persist a token from signup itself — the account
        // isn't verified yet at this point. Saving it here would let an
        // unverified user reach Home on a later cold start (splash sees a
        // saved token and restores the session without the OTP step ever
        // completing). The token is only saved once OTP verify succeeds
        // (see otp_notifier.dart's verify()).
        // UA-7: explicitly clear every field error and the auth error
        // message — status alone gates the error dialog, but the inline
        // per-field error text isn't gated by status at all, so a stale
        // message from an earlier failed attempt would otherwise silently
        // persist and reappear if the user navigates back to this screen.
        state = state.copyWith(
          status: SignUpStatus.success,
          fullNameError: null,
          emailError: null,
          passwordError: null,
          confirmPasswordError: null,
          authErrorMessage: null,
        );
      } else {
        final errorMessage =
            _extractMessage(response) ??
            'Failed to create account. Please try again.';
        state = state.copyWith(
          status: SignUpStatus.authError,
          authErrorMessage: errorMessage,
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response != null
          ? _extractMessage(e.response!)
          : 'Unable to sign up. Please check your internet connection.';
      state = state.copyWith(
        status: SignUpStatus.authError,
        authErrorMessage: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: SignUpStatus.authError,
        authErrorMessage: 'An error occurred during sign up. Please try again.',
      );
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

}
