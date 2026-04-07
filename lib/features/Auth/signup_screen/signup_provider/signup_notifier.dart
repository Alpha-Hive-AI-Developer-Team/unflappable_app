import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_state.dart';

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(const SignUpState());

  // ── Field setters with real-time validation ──────────────────────────────

  void setFullName(String v) {
    final error = _validateFullName(v);
    state = state.copyWith(
      fullName: v,
      fullNameError: error, // null when valid, message when invalid
      status: SignUpStatus.idle,
    );
  }

  void setEmail(String v) {
    final error = _validateEmail(v);
    state = state.copyWith(
      email: v,
      emailError: error,
      status: SignUpStatus.idle,
    );
  }

  void setPassword(String v) {
    final error = _validatePassword(v);
    state = state.copyWith(
      password: v,
      passwordError: error,
      status: SignUpStatus.idle,
    );
  }

  void setConfirmPassword(String v) {
    final error = _validateConfirmPassword(v);
    state = state.copyWith(
      confirmPassword: v,
      confirmPasswordError: error,
      status: SignUpStatus.idle,
    );
  }

  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void clearError() =>
      state = state.copyWith(status: SignUpStatus.idle, authErrorMessage: null);

  // ── Per-field validators (shared by real-time + submit) ──────────────────

  String? _validateFullName(String v) {
    if (v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
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
    final confirmPasswordError = _validateConfirmPassword(state.confirmPassword);

    final hasErrors =
        fullNameError != null || emailError != null || passwordError != null || confirmPasswordError != null;

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
      // TODO: replace with real auth repository call
      // e.g. await ref.read(authRepositoryProvider).signUp(...)
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(status: SignUpStatus.success);
    } catch (e) {
      // Map repository / API exceptions to a human-readable message
      final message = _mapErrorMessage(e);
      state = state.copyWith(
        status: SignUpStatus.authError,
        authErrorMessage: message,
      );
    }
  }

  /// Convert exceptions from the auth repository into user-friendly messages.
  /// Expand this when you wire up the real API.
  String _mapErrorMessage(Object e) {
    // Example for Firebase / custom backend errors:
    // if (e is FirebaseAuthException) { ... }
    return 'An error occurred during sign up. Please try again.';
  }
}
