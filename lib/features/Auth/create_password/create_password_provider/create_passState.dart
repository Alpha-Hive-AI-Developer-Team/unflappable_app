enum CreatePasswordStatus { idle, loading, validationError, authError, success }

const _keep = Object();

class CreatePasswordState {
  final String newPassword;
  final String confirmPassword;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;
  final String? newPasswordError;
  final String? confirmPasswordError;
  final String? authErrorMessage;
  final CreatePasswordStatus status;

  const CreatePasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.isLoading = false,
    this.newPasswordError,
    this.confirmPasswordError,
    this.authErrorMessage,
    this.status = CreatePasswordStatus.idle,
  });

  bool get passwordsMatch =>
      newPassword.isNotEmpty && newPassword == confirmPassword;

  bool get hasAuthError => status == CreatePasswordStatus.authError;

  bool get showErrorOverlay =>
      status == CreatePasswordStatus.authError ||
      status == CreatePasswordStatus.validationError;

  bool get isSuccess => status == CreatePasswordStatus.success;

  CreatePasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? obscureNew,
    bool? obscureConfirm,
    bool? isLoading,
    Object? newPasswordError = _keep,
    Object? confirmPasswordError = _keep,
    Object? authErrorMessage = _keep,
    CreatePasswordStatus? status,
  }) => CreatePasswordState(
    newPassword: newPassword ?? this.newPassword,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    obscureNew: obscureNew ?? this.obscureNew,
    obscureConfirm: obscureConfirm ?? this.obscureConfirm,
    isLoading: isLoading ?? this.isLoading,
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
