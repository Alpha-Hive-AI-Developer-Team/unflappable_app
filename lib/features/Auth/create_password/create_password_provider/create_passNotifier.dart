import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/service/auth_service.dart';

import '../create_password_export.dart';

class CreatePasswordNotifier extends StateNotifier<CreatePasswordState> {
  CreatePasswordNotifier() : super(const CreatePasswordState());

  void setNewPassword(String v) {
    final newPasswordError = _validatePassword(v);
    final confirmPasswordError =
        state.confirmPassword.isNotEmpty && state.confirmPassword != v
        ? 'Passwords do not match'
        : null;

    state = state.copyWith(
      newPassword: v,
      newPasswordError: newPasswordError,
      confirmPasswordError: confirmPasswordError,
      status: CreatePasswordStatus.idle,
    );
  }

  void setConfirmPassword(String v) {
    final confirmPasswordError = _validateConfirmPassword(v);

    state = state.copyWith(
      confirmPassword: v,
      confirmPasswordError: confirmPasswordError,
      status: CreatePasswordStatus.idle,
    );
  }

  void toggleObscureNew() =>
      state = state.copyWith(obscureNew: !state.obscureNew);

  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  Future<bool> submit({required String resetToken}) async {
    final newPasswordError = _validatePassword(state.newPassword);
    final confirmPasswordError = _validateConfirmPassword(
      state.confirmPassword,
    );
    final hasErrors = newPasswordError != null || confirmPasswordError != null;

    if (resetToken.isEmpty) {
      state = state.copyWith(
        authErrorMessage: 'Unable to reset password. Reset token is missing.',
        status: CreatePasswordStatus.authError,
      );
      return false;
    }

    if (hasErrors) {
      state = state.copyWith(
        newPasswordError: newPasswordError,
        confirmPasswordError: confirmPasswordError,
        authErrorMessage:
            'Please fix the highlighted fields before continuing.',
        status: CreatePasswordStatus.validationError,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      status: CreatePasswordStatus.loading,
    );

    try {
      final response = await AuthService.resetPassword(
        resetToken: resetToken,
        newPassword: state.newPassword.trim(),
        confirmPassword: state.confirmPassword.trim(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          status: CreatePasswordStatus.success,
        );
        return true;
      }

      final errorMessage = _extractMessage(response) ??
          'Unable to reset password. Please try again.';
      state = state.copyWith(
        isLoading: false,
        status: CreatePasswordStatus.authError,
        authErrorMessage: errorMessage,
      );
      return false;
    } on DioException catch (e) {
      final message = e.response != null
          ? _extractMessage(e.response!) ??
              'Unable to reset password. Please try again.'
          : 'Unable to connect to the server. Please try again.';
      state = state.copyWith(
        isLoading: false,
        status: CreatePasswordStatus.authError,
        authErrorMessage: message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: CreatePasswordStatus.authError,
        authErrorMessage: 'Unable to reset password. Please try again.',
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

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(v)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String v) {
    if (v.isEmpty) return 'Confirm password is required';
    if (v != state.newPassword) return 'Passwords do not match';
    return null;
  }
}
