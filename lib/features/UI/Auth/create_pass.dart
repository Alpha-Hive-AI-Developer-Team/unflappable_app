import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_paddings.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/provider/Auth/Create%20Password/create_passProvider.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_header.dart';
import 'package:unflappable/features/widgets/Auth%20widgets/auth_widgets.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';

class CreateNewPasswordScreen extends ConsumerWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const _CreatePasswordBody().withAuthScreenPadding(),
    );
  }
}

class _CreatePasswordBody extends ConsumerWidget {
  const _CreatePasswordBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPasswordProvider);
    final notifier = ref.read(createPasswordProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          title: 'Create New Password',
          subtitle:
              'Create a secure new password to protect your account and keep your information safe always.',
        ),

        SizedBox(height: ScreenUtils.vXxl),

        FieldLabel('New Password'),
        SizedBox(height: ScreenUtils.vSm),
        AuthTextField(
          hint: 'Enter new password',
          obscureText: state.obscureNew,
          onChanged: notifier.setNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureNew
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: ScreenUtils.iconSm,
              color: AppColors.bodyText,
            ),
            onPressed: notifier.toggleObscureNew,
          ),
        ),

        SizedBox(height: ScreenUtils.vMd),

        FieldLabel('Confirm New Password'),
        SizedBox(height: ScreenUtils.vSm),
        AuthTextField(
          hint: 'Confirm new password',
          obscureText: state.obscureConfirm,
          onChanged: notifier.setConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              state.obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: ScreenUtils.iconSm,
              color: AppColors.bodyText,
            ),
            onPressed: notifier.toggleObscureConfirm,
          ),
        ),

        const Spacer(),

        PrimaryButton(
          label: 'Start Resetting Password',
          isLoading: state.isLoading,
          onTap: state.passwordsMatch
              ? () async {
                  await notifier.submit();
                  if (context.mounted) context.go(AppRoutes.login);
                }
              : null,
        ),
      ],
    );
  }
}
