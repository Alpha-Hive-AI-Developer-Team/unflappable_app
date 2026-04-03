import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_provider.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_header.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_widgets.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const _SignUpBody().withAuthScreenPadding(),
    );
  }
}

class _SignUpBody extends ConsumerWidget {
  const _SignUpBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signUpProvider);
    final notifier = ref.read(signUpProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          title: 'Create Account',
          subtitle: 'Start your journey to unflappable focus.',
        ),

        SizedBox(height: ScreenUtils.vXxl),

        // Full Name
        FieldLabel('Full Name'),
        SizedBox(height: ScreenUtils.vSm),
        AuthTextField(
          hint: 'Sami Perwaiz',
          onChanged: notifier.setFullName,
          obscureText: false,
        ),

        SizedBox(height: ScreenUtils.vLg),

        // Email
        FieldLabel('Email'),
        SizedBox(height: ScreenUtils.vSm),
        AuthTextField(
          hint: 'samiperwaiz@gmail.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.setEmail,
          obscureText: false,
        ),

        SizedBox(height: ScreenUtils.vLg),

        // Password
        FieldLabel('Password'),
        SizedBox(height: ScreenUtils.vSm),
        AuthTextField(
          hint: 'Create Your Password',
          obscureText: state.obscurePassword,
          onChanged: notifier.setPassword,
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

        const Spacer(),

        // Create Account button
        PrimaryButton(
          label: 'Create Account',
          isLoading: state.isLoading,
          onTap: () => notifier.submit(),
        ),

        SizedBox(height: ScreenUtils.vMd),

        // Apple sign in
        AppleButton(),

        SizedBox(height: ScreenUtils.vMd),

        // Already have account
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
    );
  }
}
