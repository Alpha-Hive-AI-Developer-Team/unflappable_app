import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/session_provider_reset.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_provider.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_state.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/navbar_wrapper/home_shell.dart';
import 'package:unflappable/features/widgets/Common/app_header.dart';
import 'package:unflappable/features/widgets/Common/error_dialog.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_widgets.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/legal_links_row.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);

    // Navigate away on success and update user provider
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.isSuccess) {
        final email = next.authenticatedEmail.isNotEmpty
            ? next.authenticatedEmail
            : next.email;
        final displayName = next.authenticatedName.isNotEmpty
            ? next.authenticatedName
            : _deriveNameFromEmail(email);
        final id = next.authenticatedUserId.isNotEmpty
            ? next.authenticatedUserId
            : email;

        ref
            .read(userProvider.notifier)
            .setUserInfo(
              id: id,
              email: email,
              name: displayName,
              isPro: false,
              onboardingCompleted: next.authenticatedOnboardingCompleted,
              authProvider: next.authenticatedAuthProvider,
              hasPassword: next.authenticatedHasPassword,
            );

        unawaited(ref.read(userProvider.notifier).syncSubscriptionFromApi());

        resetSessionScopedProviders(ref);
        ref.read(navIndexProvider.notifier).state = 0;
        // UA-6: this toast persists across the navigation below, landing
        // on Home/Onboarding's own bottom-pinned button — give it the same
        // clearance as OTP/Forgot Password's toasts.
        AppSnackbar.showSuccess(
          context,
          message: 'Login successful!',
          extraBottomMargin: 72.h,
        );
        // UA-11 / UN-43: resume onboarding instead of opening Home if this
        // account never finished it (e.g. abandoned mid-flow last session).
        context.go(
          next.authenticatedOnboardingCompleted
              ? AppRoutes.home
              : AppRoutes.onboarding,
        );
        ref.read(loginProvider.notifier).clearError();
        return;
      }

      // UA-30: an unverified-email login attempt previously dead-ended on a
      // generic error with no way to reach the OTP screen. Redirect there
      // instead, reusing the same signup-verification flow.
      if (next.isEmailNotVerified) {
        final email = next.email.trim();
        ref.read(loginProvider.notifier).clearError();
        AppSnackbar.showError(
          context,
          message: 'Please verify your email to continue.',
          extraBottomMargin: 72.h,
        );
        context.push(
          '${AppRoutes.otpVerification}?purpose=signup&email=${Uri.encodeComponent(email)}',
        );
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
              child: ErrorDialog(
                title: state.hasValidationError
                    ? 'Invalid Fields'
                    : 'Login Failed',
                message:
                    state.authErrorMessage ??
                    'An unexpected error occurred. Please try again.',
                onTryAgain: () => ref.read(loginProvider.notifier).clearError(),
              ),
            ),
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
    final showAppleSignIn = defaultTargetPlatform == TargetPlatform.iOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppHeader(
          title: 'Welcome back',
          subtitle: 'Please enter your details to sign in.',
        ),

        SizedBox(height: ScreenUtils.vXxl),

        // ── Email ────────────────────────────────────────────────────────
        FieldLabel('Email'),
        SizedBox(height: ScreenUtils.vSm),
        AuthTextField(
          hint: 'Enter your email',
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
          hint: 'Enter your password',
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
            // UN-58: don't let the user navigate away while a login/apple
            // request is still in flight.
            onTap: (state.isLoginLoading || state.isAppleLoading)
                ? null
                : () => context.push(AppRoutes.forgotPassword),
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
        // UN-58: each button previously only checked its own loading flag,
        // so Apple Sign-In stayed tappable during an email/password login
        // (and vice versa) — guard both against either flag.
        PrimaryButton(
          label: 'Sign in',
          isLoading: state.isLoginLoading,
          onTap: state.isAppleLoading ? null : () => notifier.submit(),
        ),

        if (showAppleSignIn) ...[
          SizedBox(height: ScreenUtils.vMd),
          AppleButton(
            isLoading: state.isAppleLoading,
            onTap: state.isLoginLoading ? null : notifier.signInWithApple,
          ),
          SizedBox(height: ScreenUtils.vMd),
        ] else
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
                    // UA-3: go() instead of push() — toggling Login/Signup
                    // repeatedly no longer stacks routes that the iOS
                    // swipe-back gesture can tunnel through to Welcome.
                    onTap: (state.isLoginLoading || state.isAppleLoading)
                        ? null
                        : () => context.go(AppRoutes.signup),
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

        SizedBox(height: ScreenUtils.vSm),
        LegalLinksRow(enabled: !(state.isLoginLoading || state.isAppleLoading)),
      ],
    );
  }
}

String _deriveNameFromEmail(String email) {
  final localPart = email.split('@').first;
  if (localPart.isEmpty) return 'User';
  final segments = localPart.split(RegExp(r'[._\- ]+'));
  return segments
      .map(
        (part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .where((part) => part.isNotEmpty)
      .join(' ');
}
