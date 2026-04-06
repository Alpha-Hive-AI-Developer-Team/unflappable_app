import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Onboarding/Provider/onboarding%20state.dart';
import 'package:unflappable/features/Onboarding/Model/onboarding_model.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void selectOption(int optionIndex) {
    final updated = Map<int, int>.from(state.answers);
    updated[state.currentStep] = optionIndex;
    state = state.copyWith(answers: updated);
  }

  void nextStep() {
    if (state.currentStep < questions.length - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> completeSetup() async {
    state = state.copyWith(isLoading: true);
    // TODO: persist answers, call onboarding repository
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }
}
