class OnboardingQuestion {
  final String question;
  final List<String> options;
  final String continueLabel;

  const OnboardingQuestion({
    required this.question,
    required this.options,
    this.continueLabel = 'Continue',
  });
}

const questions = [
  OnboardingQuestion(
    question: 'What is your primary role?',
    options: [
      'Founder / CEO',
      'Entrepreneur',
      'Creator',
      'Coach',
      'Manager',
      'Other',
    ],
  ),
  OnboardingQuestion(
    question: 'What throws you off most?',
    options: [
      'Overwhelm',
      'Procrastination',
      'Inconsistency',
      'Lack of Focus',
      'Stress',
    ],
  ),
  OnboardingQuestion(
    question: 'What do you want most?',
    options: [
      'More Follow-through',
      'Better Clarity',
      'Better Productivity',
      'More Calm Under Pressure',
    ],
  ),
  OnboardingQuestion(
    question: 'Would you like daily reminders?',
    options: ['Yes, keep me on track', 'No, I will manage myself'],
    continueLabel: 'Complete Setup',
  ),
];
