import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Onboarding/Provider/onboarding%20state.dart';
import 'package:unflappable/features/Onboarding/Provider/onboarding_notifier.dart';

final onboardingProvider =
    StateNotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>(
      (_) => OnboardingNotifier(),
    );
