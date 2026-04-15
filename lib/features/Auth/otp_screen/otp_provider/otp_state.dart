enum OtpPurpose { signup, forgotPassword }

class OtpState {
  final List<String> digits;
  final int secondsLeft;
  final bool isLoading;

  const OtpState({
    this.digits = const ['', '', '', ''],
    this.secondsLeft = 56,
    this.isLoading = false,
  });

  bool get isComplete => digits.every((d) => d.isNotEmpty);

  OtpState copyWith({
    List<String>? digits,
    int? secondsLeft,
    bool? isLoading,
  }) => OtpState(
    digits: digits ?? this.digits,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    isLoading: isLoading ?? this.isLoading,
  );
}
