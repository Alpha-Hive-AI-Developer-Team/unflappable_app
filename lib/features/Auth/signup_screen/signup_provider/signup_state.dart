class SignUpState {
  final String fullName;
  final String email;
  final String password;
  final bool obscurePassword;
  final bool isLoading;

  const SignUpState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.isLoading = false,
  });

  SignUpState copyWith({
    String? fullName,
    String? email,
    String? password,
    bool? obscurePassword,
    bool? isLoading,
  }) => SignUpState(
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    password: password ?? this.password,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    isLoading: isLoading ?? this.isLoading,
  );
}
