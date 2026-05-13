import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Onboarding/Model/onboarding_model.dart';
import 'package:unflappable/features/Onboarding/Provider/onboarding_provider.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class OnboardingQuestionnaireScreen extends ConsumerWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            const _StepProgressBar(),

            // Content — scrollable in case options overflow on small screens
            Expanded(child: const _QuestionBody()),

            // Bottom button
            const _BottomButton(),
          ],
        ).withScreenPadding(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESS BAR
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressBar extends ConsumerWidget {
  const _StepProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(onboardingProvider.select((s) => s.currentStep));
    final total = questions.length;
    final progress = (step + 1) / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(100.r),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4.h,
        backgroundColor: AppColors.secondarySurface,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUESTION BODY
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionBody extends ConsumerWidget {
  const _QuestionBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final question = questions[state.currentStep];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(state.currentStep),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: ScreenUtils.vXl),
          children: [
            // Question title
            Text(
              question.question,
              style: AppTextStyles.headingLG.copyWith(
                color: AppColors.headingText,
              ),
            ),

            SizedBox(height: ScreenUtils.vXl),

            // Options
            ...List.generate(question.options.length, (i) {
              final isSelected = state.currentAnswer == i;
              return Padding(
                padding: EdgeInsets.only(bottom: ScreenUtils.vSm),
                child: _OptionTile(
                  label: question.options[i],
                  isSelected: isSelected,
                  onTap: () =>
                      ref.read(onboardingProvider.notifier).selectOption(i),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTION TILE
// ─────────────────────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 56.h,
        width: 400.w,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtils.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryWithOpacity(0.18),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLG.copyWith(
                  color: isSelected ? AppColors.white : AppColors.bodyText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                size: ScreenUtils.iconMd,
                color: AppColors.white,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _BottomButton extends ConsumerWidget {
  const _BottomButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final question = questions[state.currentStep];

    return PrimaryButton(
      label: question.continueLabel,
      isLoading: state.isLoading,
      onTap: state.hasAnswer
          ? () async {
              if (state.isLastStep) {
                try {
                  await notifier.completeSetup();
                  if (context.mounted) {
                    await ref
                        .read(userProvider.notifier)
                        .restoreSessionIfNeeded();
                    if (!context.mounted) return;
                    AppSnackbar.showSuccess(context,
                        message: 'Onboarding complete!');
                    context.go(AppRoutes.home);
                  }
                } catch (_) {
                  if (context.mounted) {
                    AppSnackbar.showError(
                      context,
                      message:
                          'Unable to complete onboarding. Please try again.',
                    );
                  }
                }
              } else {
                notifier.nextStep();
              }
            }
          : null,
    );
  }
}
