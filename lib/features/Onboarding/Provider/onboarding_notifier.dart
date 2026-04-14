import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Onboarding/Model/onboarding_model.dart';
import 'package:unflappable/features/Onboarding/Provider/onboarding state.dart';
import 'package:unflappable/service/onboarding_service.dart';

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
    try {
      await OnboardingService.complete(answers: state.answers);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
