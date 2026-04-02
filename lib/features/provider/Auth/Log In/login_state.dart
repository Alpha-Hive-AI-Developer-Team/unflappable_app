enum LoginStatus { idle, loading, error }

class LoginState {
  final String email;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;

  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.idle,
  });

  bool get hasError => status == LoginStatus.error;
  bool get isLoading => status == LoginStatus.loading;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    status: status ?? this.status,
  );
}
