enum ChangePasswordStatus { idle, loading, validationError, authError, success }

const _keep = Object();

class ChangePasswordState {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;
  final String? currentPasswordError;
  final String? newPasswordError;
  final String? confirmPasswordError;
  final String? authErrorMessage;
  final ChangePasswordStatus status;

  const ChangePasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureCurrent = true,
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.isLoading = false,
    this.currentPasswordError,
    this.newPasswordError,
    this.confirmPasswordError,
    this.authErrorMessage,
    this.status = ChangePasswordStatus.idle,
  });

  bool get passwordsMatch =>
      newPassword.isNotEmpty && newPassword == confirmPassword;

  bool get showErrorOverlay =>
      status == ChangePasswordStatus.authError ||
      status == ChangePasswordStatus.validationError;

  bool get isSuccess => status == ChangePasswordStatus.success;

  ChangePasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? obscureCurrent,
    bool? obscureNew,
    bool? obscureConfirm,
    bool? isLoading,
    Object? currentPasswordError = _keep,
    Object? newPasswordError = _keep,
    Object? confirmPasswordError = _keep,
    Object? authErrorMessage = _keep,
    ChangePasswordStatus? status,
  }) => ChangePasswordState(
    currentPassword: currentPassword ?? this.currentPassword,
    newPassword: newPassword ?? this.newPassword,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    obscureCurrent: obscureCurrent ?? this.obscureCurrent,
    obscureNew: obscureNew ?? this.obscureNew,
    obscureConfirm: obscureConfirm ?? this.obscureConfirm,
    isLoading: isLoading ?? this.isLoading,
    currentPasswordError: currentPasswordError == _keep
        ? this.currentPasswordError
        : currentPasswordError as String?,
    newPasswordError: newPasswordError == _keep
        ? this.newPasswordError
        : newPasswordError as String?,
    confirmPasswordError: confirmPasswordError == _keep
        ? this.confirmPasswordError
        : confirmPasswordError as String?,
    authErrorMessage: authErrorMessage == _keep
        ? this.authErrorMessage
        : authErrorMessage as String?,
    status: status ?? this.status,
  );
}
