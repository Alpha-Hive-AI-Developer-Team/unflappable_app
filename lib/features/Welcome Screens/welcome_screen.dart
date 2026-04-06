import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _OnboardingBody().withScreenPadding(top: 92.h),
    );
  }
}

class _OnboardingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Logo ──────────────────────────────────────────────────────────────
        Image.asset(logo, width: 106.w, height: 110.h),

        SizedBox(height: ScreenUtils.vXl),

        // ── Tagline ───────────────────────────────────────────────────────────
        _TaglineSection(),

        const Spacer(flex: 3),

        // ── Auth Buttons ──────────────────────────────────────────────────────
        _AuthButtons(),
      ],
    );
  }
}

// ── Tagline ───────────────────────────────────────────────────────────────────

class _TaglineSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Stay Calm. Execute Anyway.',
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLG.copyWith(color: AppColors.headingText),
        ),
        SizedBox(height: ScreenUtils.vSm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Text(
            ' Stay clear under pressure and follow through on what matters.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLG.copyWith(color: AppColors.bodyText),
          ),
        ),
      ],
    );
  }
}

// ── Auth Buttons ──────────────────────────────────────────────────────────────

class _AuthButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sign in with Apple
        _AppleSignInButton(),

        SizedBox(height: ScreenUtils.vMd),

        // Sign Up
        PrimaryButton(
          label: 'Sign Up',
          onTap: () => context.push(AppRoutes.signup),
          isLoading: false,
        ),

        SizedBox(height: ScreenUtils.vMd),

        // Log In
        SecondaryButton(
          label: 'Log In',
          onTap: () => context.push(AppRoutes.login),
        ),
      ],
    );
  }
}

class _AppleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtils.buttonHeight,
      child: OutlinedButton(
        onPressed: () {
          // TODO: handle Apple sign-in
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
          ),
          backgroundColor: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple,
              size: ScreenUtils.iconMd,
              color: AppColors.headingText,
            ),
            SizedBox(width: ScreenUtils.sm),
            Text(
              'Sign in with Apple',
              style: AppTextStyles.labelLG.copyWith(
                color: AppColors.headingText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
