enum LoginStatus { idle, loading, validationError, authError, success }

const _keep = Object();

class LoginState {
  final String email;
  final String password;
  final bool obscurePassword;
  final LoginStatus loginStatus;
  final LoginStatus appleStatus;
  final String? emailError;
  final String? passwordError;
  final String? authErrorMessage;
  final String authenticatedEmail;
  final String authenticatedName;
  final String authenticatedUserId;

  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.loginStatus = LoginStatus.idle,
    this.appleStatus = LoginStatus.idle,
    this.emailError,
    this.passwordError,
    this.authErrorMessage,
    this.authenticatedEmail = '',
    this.authenticatedName = '',
    this.authenticatedUserId = '',
  });

  bool get isLoginLoading => loginStatus == LoginStatus.loading;
  bool get isAppleLoading => appleStatus == LoginStatus.loading;

  bool get hasValidationError => loginStatus == LoginStatus.validationError;
  bool get hasAuthError =>
      loginStatus == LoginStatus.authError ||
      appleStatus == LoginStatus.authError;

  // Show overlay for both validation and auth errors
  bool get showErrorOverlay => hasValidationError || hasAuthError;

  bool get isSuccess =>
      loginStatus == LoginStatus.success || appleStatus == LoginStatus.success;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginStatus? loginStatus,
    LoginStatus? appleStatus,
    Object? emailError = _keep,
    Object? passwordError = _keep,
    Object? authErrorMessage = _keep,
    String? authenticatedEmail,
    String? authenticatedName,
    String? authenticatedUserId,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      loginStatus: loginStatus ?? this.loginStatus,
      appleStatus: appleStatus ?? this.appleStatus,
      emailError: emailError == _keep ? this.emailError : emailError as String?,
      passwordError: passwordError == _keep
          ? this.passwordError
          : passwordError as String?,
      authErrorMessage: authErrorMessage == _keep
          ? this.authErrorMessage
          : authErrorMessage as String?,
      authenticatedEmail: authenticatedEmail ?? this.authenticatedEmail,
      authenticatedName: authenticatedName ?? this.authenticatedName,
      authenticatedUserId: authenticatedUserId ?? this.authenticatedUserId,
    );
  }
}
