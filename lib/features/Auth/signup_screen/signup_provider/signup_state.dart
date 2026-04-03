enum SignUpStatus { idle, loading, validationError, authError, success }

// Sentinel used to distinguish "explicitly set to null" from "not provided"
const _keep = Object();

class SignUpState {
  final String fullName;
  final String email;
  final String password;
  final bool obscurePassword;
  final String? fullNameError;
  final String? emailError;
  final String? passwordError;
  final String? authErrorMessage; // ← real error message shown in dialog
  final SignUpStatus status;

  const SignUpState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.fullNameError,
    this.emailError,
    this.passwordError,
    this.authErrorMessage,
    this.status = SignUpStatus.idle,
  });

  bool get isLoading => status == SignUpStatus.loading;

  // Shows the blur + dialog overlay
  bool get hasAuthError => status == SignUpStatus.authError;

  // Also show overlay on validation error (per requirement)
  bool get showErrorOverlay =>
      status == SignUpStatus.authError ||
      status == SignUpStatus.validationError;

  bool get isSuccess => status == SignUpStatus.success;

  /// Sentinel-safe copyWith: pass `clearFullNameError: true` to explicitly
  /// null a field; omit to keep the current value.
  SignUpState copyWith({
    String? fullName,
    String? email,
    String? password,
    bool? obscurePassword,
    Object? fullNameError = _keep,
    Object? emailError = _keep,
    Object? passwordError = _keep,
    Object? authErrorMessage = _keep,
    SignUpStatus? status,
  }) {
    return SignUpState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      fullNameError: fullNameError == _keep
          ? this.fullNameError
          : fullNameError as String?,
      emailError: emailError == _keep ? this.emailError : emailError as String?,
      passwordError: passwordError == _keep
          ? this.passwordError
          : passwordError as String?,
      authErrorMessage: authErrorMessage == _keep
          ? this.authErrorMessage
          : authErrorMessage as String?,
      status: status ?? this.status,
    );
  }
}
