import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Auth/forget_password/forget_password_provider/forget_passProvider.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_header.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_widgets.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const _ForgotPasswordBody().withAuthScreenPadding(),
    );
  }
}

class _ForgotPasswordBody extends ConsumerWidget {
  const _ForgotPasswordBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          title: 'Forgot Password',
          subtitle:
              "Enter your email and we'll send you a link to reset your password.",
        ),

        SizedBox(height: ScreenUtils.vXxl),

        FieldLabel('Email'),
        SizedBox(height: ScreenUtils.vSm),
        AuthTextField(
          hint: 'samiperwaiz@gmail.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.setEmail,
          obscureText: false,
        ),

        const Spacer(),

        Row(
          children: [
            Expanded(
              child: SecondaryButton(label: 'Back', onTap: () => context.pop()),
            ),
            SizedBox(width: ScreenUtils.md),
            Expanded(
              child: PrimaryButton(
                label: 'Next',
                isLoading: state.isLoading,
                onTap: () async {
                  await notifier.submit();
                  if (context.mounted) context.push(AppRoutes.otpVerification);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
