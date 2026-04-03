enum LoginStatus { idle, loading, error, success }

class LoginState {
  final String email;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.idle,
    this.errorMessage,
  });

  bool get hasError => status == LoginStatus.error;
  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
