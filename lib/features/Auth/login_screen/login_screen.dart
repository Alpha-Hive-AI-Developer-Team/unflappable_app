import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_provider.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_state.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_header.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_error_dialog.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_widgets.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);

    // Navigate away on success
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        context.go(AppRoutes.onboarding);
        ref.read(loginProvider.notifier).clearError();
    // Listen for success and navigate to home
    ref.listen(loginProvider, (previous, next) {
      if (next.isSuccess) {
        context.pushReplacementNamed('home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Main body ────────────────────────────────────────────────────
          const _LoginBody().withAuthScreenPadding(),

          // ── Error overlay (validation OR auth error) ─────────────────────
          if (state.showErrorOverlay) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
            Center(
              child: AuthErrorDialog(
                title: state.status == LoginStatus.validationError
                    ? 'Invalid Fields'
                    : 'Login Failed',
                message:
                    state.authErrorMessage ??
                    'An unexpected error occurred. Please try again.',
                onTryAgain: () => ref.read(loginProvider.notifier).clearError(),
              ),
            ),

            // ✅ Center Dialog
            Center(child: _LoginErrorDialog(errorMessage: state.errorMessage)),
          ],
        ],
      ),
    );
  }
}

// ── Login Body ────────────────────────────────────────────────────────────────

class _LoginBody extends ConsumerWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          title: 'Welcome back',
          subtitle: 'Please enter your details to sign in.',
        ),

        SizedBox(height: ScreenUtils.vXxl),

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
          hint: '••••••••',
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

        Container(
          margin: EdgeInsets.only(top: ScreenUtils.vSm),
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.forgotPassword),
            child: Text(
              'Forgot password',
              style: AppTextStyles.labelMD.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const Spacer(),

        // ── Sign in button ───────────────────────────────────────────────
        PrimaryButton(
          label: 'Sign in',
          isLoading: state.isLoading,
          onTap: () => notifier.submit(),
        ),

        SizedBox(height: ScreenUtils.vMd),
        AppleButton(),
        SizedBox(height: ScreenUtils.vMd),

        // ── Don't have an account ────────────────────────────────────────
        Center(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySM.copyWith(color: AppColors.bodyText),
              children: [
                const TextSpan(text: "Don't have an account? "),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.signup),
                    child: Text(
                      'Sign up',
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
    );
  }
}

class _LoginErrorDialog extends ConsumerWidget {
  final String? errorMessage;

  const _LoginErrorDialog({this.errorMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loginProvider.notifier);

    return Container(
      width: 400.w,
      height: 242.h,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.md, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: ScreenUtils.iconMd,
            ),
          ),
          SizedBox(height: ScreenUtils.vMd),
          Text(
            'Login Failure',
            style: AppTextStyles.labelLG.copyWith(color: AppColors.headingText),
          ),
          SizedBox(height: ScreenUtils.vSm),
          Text(
            errorMessage ?? "Email or password didn't match",
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: ScreenUtils.buttonHeight,
            child: OutlinedButton(
              onPressed: () {
                notifier.clearError();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                ),
              ),
              child: Text(
                'Try Again',
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.labelText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
