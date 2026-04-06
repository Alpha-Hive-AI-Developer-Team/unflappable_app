enum ForgotPasswordStatus { idle, loading, validationError, authError, success }

// Sentinel used to distinguish "explicitly set to null" from "not provided"
const _keep = Object();

class ForgotPasswordState {
  final String email;
  final bool isLoading;
  final String? emailError;
  final String? authErrorMessage;
  final ForgotPasswordStatus status;

  const ForgotPasswordState({
    this.email = '',
    this.isLoading = false,
    this.emailError,
    this.authErrorMessage,
    this.status = ForgotPasswordStatus.idle,
  });

  bool get hasAuthError => status == ForgotPasswordStatus.authError;

  bool get showErrorOverlay =>
      status == ForgotPasswordStatus.authError ||
      status == ForgotPasswordStatus.validationError;

  bool get isSuccess => status == ForgotPasswordStatus.success;

  ForgotPasswordState copyWith({
    String? email,
    bool? isLoading,
    Object? emailError = _keep,
    Object? authErrorMessage = _keep,
    ForgotPasswordStatus? status,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      emailError: emailError == _keep ? this.emailError : emailError as String?,
      authErrorMessage: authErrorMessage == _keep
          ? this.authErrorMessage
          : authErrorMessage as String?,
      status: status ?? this.status,
    );
  }
}
