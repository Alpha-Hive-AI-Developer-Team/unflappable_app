import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_provider.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_state.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_header.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_widgets.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_error_dialog.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpProvider);

    // Navigate away on success
    ref.listen<SignUpState>(signUpProvider, (previous, next) {
      if (next.isSuccess) {
        AppSnackbar.showSuccess(
          context,
          message: 'Account created successfully!',
        );
        context.go(AppRoutes.login);
        ref.read(signUpProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Main body ────────────────────────────────────────────────────
          const _SignUpBody().withAuthScreenPadding(),

          // ── Error overlay (validation OR auth error) ─────────────────────
          if (state.showErrorOverlay) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
            Center(
              child: AuthErrorDialog(
                title: state.status == SignUpStatus.validationError
                    ? 'Invalid Fields'
                    : 'Sign Up Failed',
                // Show the dynamic message stored in state
                message:
                    state.authErrorMessage ??
                    'An unexpected error occurred. Please try again.',
                onTryAgain: () =>
                    ref.read(signUpProvider.notifier).clearError(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SignUpBody extends ConsumerWidget {
  const _SignUpBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpProvider);
    final notifier = ref.read(signUpProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeader(
            title: 'Create Account',
            subtitle: 'Start your journey to unflappable focus.',
          ),

          SizedBox(height: ScreenUtils.vXxl),

          // ── Full Name ────────────────────────────────────────────────────
          FieldLabel('Full Name'),
          SizedBox(height: ScreenUtils.vSm),
          AuthTextField(
            hint: 'Sami Perwaiz',
            onChanged: notifier.setFullName,
            obscureText: false,
            errorText: state.fullNameError,
          ),

          SizedBox(height: ScreenUtils.vLg),

          // ── Email ────────────────────────────────────────────────────────
          FieldLabel('Email'),
          SizedBox(height: ScreenUtils.vSm),
          AuthTextField(
            hint: 'samiperwaiz@gmail.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.setEmail,
            obscureText: false,
            errorText: state.emailError,
          ),

          SizedBox(height: ScreenUtils.vLg),

          // ── Password ─────────────────────────────────────────────────────
          FieldLabel('Password'),
          SizedBox(height: ScreenUtils.vSm),
          AuthTextField(
            hint: 'Create Your Password',
            obscureText: state.obscurePassword,
            onChanged: notifier.setPassword,
            errorText: state.passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: ScreenUtils.iconSm,
                color: AppColors.bodyText,
              ),
              onPressed: notifier.toggleObscure,
            ),
          ),

          SizedBox(height: 320.h),

          // ── Create Account button ────────────────────────────────────────
          PrimaryButton(
            label: 'Create Account',
            isLoading: state.isLoading,
            onTap: () => notifier.submit(context),
          ),

          SizedBox(height: ScreenUtils.vMd),

          AppleButton(),

          SizedBox(height: ScreenUtils.vMd),

          // ── Already have account ─────────────────────────────────────────
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySM.copyWith(color: AppColors.bodyText),
                children: [
                  const TextSpan(text: 'Already have an account? '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.login),
                      child: Text(
                        'Log in',
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
