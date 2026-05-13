import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'package:unflappable/features/widgets/Auth%20widgets/auth_widgets.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_provider.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_state.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/core/utils/session_provider_reset.dart';
import 'package:unflappable/features/navbar_wrapper/home_shell.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If user signs in with Apple from the welcome screen, mirror LoginScreen behavior.
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
            .setUserInfo(id: id, email: email, name: displayName, isPro: false);

        unawaited(ref.read(userProvider.notifier).syncSubscriptionFromApi());

        resetSessionScopedProviders(ref);
        ref.read(navIndexProvider.notifier).state = 0;
        AppSnackbar.showSuccess(context, message: 'Login successful!');
        context.go(AppRoutes.home);
        ref.read(loginProvider.notifier).clearError();
      }
    });

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
          'Execution Under Pressure',
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
    final showAppleSignIn = defaultTargetPlatform == TargetPlatform.iOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showAppleSignIn) ...[
          const _AppleSignInButton(),
          SizedBox(height: ScreenUtils.vMd),
        ],

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

class _AppleSignInButton extends ConsumerWidget {
  const _AppleSignInButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    return AppleButton(
      isLoading: state.isAppleLoading,
      onTap: notifier.signInWithApple,
    );
  }
}

String _deriveNameFromEmail(String email) {
  final localPart = email.split('@').first;
  if (localPart.isEmpty) return 'User';
  final segments = localPart.split(RegExp(r'[._\\- ]+'));
  return segments
      .map(
        (part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .where((part) => part.isNotEmpty)
      .join(' ');
}
