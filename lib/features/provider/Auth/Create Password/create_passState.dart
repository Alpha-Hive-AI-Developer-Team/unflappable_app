class CreatePasswordState {
  final String newPassword;
  final String confirmPassword;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;

  const CreatePasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureNew = true,
    this.obscureConfirm = true,
    this.isLoading = false,
  });

  bool get passwordsMatch =>
      newPassword.isNotEmpty && newPassword == confirmPassword;

  CreatePasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? obscureNew,
    bool? obscureConfirm,
    bool? isLoading,
  }) => CreatePasswordState(
    newPassword: newPassword ?? this.newPassword,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    obscureNew: obscureNew ?? this.obscureNew,
    obscureConfirm: obscureConfirm ?? this.obscureConfirm,
    isLoading: isLoading ?? this.isLoading,
  );
}
