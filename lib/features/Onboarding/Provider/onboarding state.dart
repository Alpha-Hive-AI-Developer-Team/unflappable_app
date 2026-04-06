import 'package:unflappable/features/Onboarding/Model/onboarding_model.dart';

class OnboardingState {
  final int currentStep;
  final Map<int, int> answers;
  final bool isLoading;

  const OnboardingState({
    this.currentStep = 0,
    this.answers = const {},
    this.isLoading = false,
  });

  int? get currentAnswer => answers[currentStep];
  bool get hasAnswer => answers.containsKey(currentStep);
  bool get isLastStep => currentStep == questions.length - 1;

  OnboardingState copyWith({
    int? currentStep,
    Map<int, int>? answers,
    bool? isLoading,
  }) => OnboardingState(
    currentStep: currentStep ?? this.currentStep,
    answers: answers ?? this.answers,
    isLoading: isLoading ?? this.isLoading,
  );
}
