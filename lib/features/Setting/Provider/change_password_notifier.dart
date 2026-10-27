import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/core/utils/network_error.dart';
import 'package:unflappable/features/Setting/Provider/change_password_state.dart';
import 'package:unflappable/service/auth_service.dart';

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  ChangePasswordNotifier() : super(const ChangePasswordState());

  void setCurrentPassword(String v) => state = state.copyWith(
    currentPassword: v,
    currentPasswordError: null,
    status: ChangePasswordStatus.idle,
  );

  void setNewPassword(String v) {
    final newPasswordError = _validateNewPassword(v);
    final confirmPasswordError =
        state.confirmPassword.isNotEmpty && state.confirmPassword != v
        ? 'Passwords do not match'
        : null;
    state = state.copyWith(
      newPassword: v,
      newPasswordError: newPasswordError,
      confirmPasswordError: confirmPasswordError,
      status: ChangePasswordStatus.idle,
    );
  }

  void setConfirmPassword(String v) {
    final error = _validateConfirmPassword(v);
    state = state.copyWith(
      confirmPassword: v,
      confirmPasswordError: error,
      status: ChangePasswordStatus.idle,
    );
  }

  void toggleObscureCurrent() =>
      state = state.copyWith(obscureCurrent: !state.obscureCurrent);

  void toggleObscureNew() =>
      state = state.copyWith(obscureNew: !state.obscureNew);

  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  void clearError() =>
      state = state.copyWith(status: ChangePasswordStatus.idle, authErrorMessage: null);

  // ── Validators — backend rule: 8+ chars, 1 uppercase, 1 number ───────────

  String? _validateNewPassword(String v) {
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
    if (v != state.newPassword) return 'Passwords do not match';
    return null;
  }

  /// US-29: [isSettingPassword] accounts have no existing password (e.g.
  /// Apple-only, `hasPassword == false`) — the Current Password field and
  /// its validation are skipped, and `POST /api/auth/password/set` is
  /// called instead of `PUT /api/auth/password/change`.
  Future<bool> submit({required bool isSettingPassword}) async {
    final currentPasswordError = (!isSettingPassword && state.currentPassword.isEmpty)
        ? 'Current password is required'
        : null;
    final newPasswordError = _validateNewPassword(state.newPassword);
    final confirmPasswordError = _validateConfirmPassword(state.confirmPassword);

    final hasErrors = currentPasswordError != null ||
        newPasswordError != null ||
        confirmPasswordError != null;

    if (hasErrors) {
      state = state.copyWith(
        currentPasswordError: currentPasswordError,
        newPasswordError: newPasswordError,
        confirmPasswordError: confirmPasswordError,
        authErrorMessage: 'Please fix the highlighted fields before continuing.',
        status: ChangePasswordStatus.validationError,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      status: ChangePasswordStatus.loading,
      authErrorMessage: null,
    );

    try {
      final response = isSettingPassword
          ? await AuthService.setPassword(newPassword: state.newPassword)
          : await AuthService.changePassword(
              currentPassword: state.currentPassword,
              newPassword: state.newPassword,
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          status: ChangePasswordStatus.success,
        );
        return true;
      }

      final message = _messageFor(response.data) ??
          'Unable to update password. Please try again.';
      state = state.copyWith(
        isLoading: false,
        status: ChangePasswordStatus.authError,
        authErrorMessage: message,
      );
      return false;
    } on DioException catch (e) {
      final message = e.response != null
          ? _messageFor(e.response!.data) ??
                'Unable to update password. Please try again.'
          : describeConnectionError(e);
      state = state.copyWith(
        isLoading: false,
        status: ChangePasswordStatus.authError,
        authErrorMessage: message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        status: ChangePasswordStatus.authError,
        authErrorMessage: 'Unable to update password. Please try again.',
      );
      return false;
    }
  }

  /// Maps the backend's `PASSWORD_ALREADY_SET` code (returned when
  /// Set Password is called on an account that already has one) to a
  /// clearer message than the raw server text.
  String? _messageFor(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['code'] == 'PASSWORD_ALREADY_SET') {
        return 'This account already has a password — use Change Password instead.';
      }
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['errors']?.toString();
    }
    return null;
  }
}

final changePasswordProvider = StateNotifierProvider.autoDispose<
    ChangePasswordNotifier, ChangePasswordState>((_) => ChangePasswordNotifier());
