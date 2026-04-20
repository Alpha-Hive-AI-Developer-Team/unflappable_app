import 'dart:ui';
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
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);

    // Navigate away on success and update user provider
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.isSuccess) {
        final email = next.email;
        final displayName = _deriveNameFromEmail(email);

        ref
            .read(userProvider.notifier)
            .setUserInfo(
              id: email,
              email: email,
              name: displayName,
              isPro: false,
            );

        resetSessionScopedProviders(ref);
        ref.read(navIndexProvider.notifier).state = 0;
        AppSnackbar.showSuccess(context, message: 'Login successful!');
        context.go(AppRoutes.home);
        ref.read(loginProvider.notifier).clearError();
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
                title: state.status == LoginStatus.validationError
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
