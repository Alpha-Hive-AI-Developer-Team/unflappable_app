import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Setting/Provider/change_password_notifier.dart';
import 'package:unflappable/features/Setting/Provider/change_password_state.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class ChangePasswordScreen extends ConsumerWidget {
  /// US-29: true for accounts with `hasPassword == false` (e.g. Apple-only)
  /// — hides the Current Password field and calls the set-password endpoint
  /// instead of change-password.
  final bool isSettingPassword;

  const ChangePasswordScreen({super.key, this.isSettingPassword = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(changePasswordProvider);
    final notifier = ref.read(changePasswordProvider.notifier);

    ref.listen<ChangePasswordState>(changePasswordProvider, (previous, next) {
      if (next.status == ChangePasswordStatus.success &&
          previous?.status != ChangePasswordStatus.success) {
        AppSnackbar.showSuccess(
          context,
          message: isSettingPassword
              ? 'Password set successfully.'
              : 'Password updated successfully.',
        );
        context.pop();
        return;
      }
      if (next.authErrorMessage != null &&
          next.authErrorMessage != previous?.authErrorMessage) {
        AppSnackbar.showError(context, message: next.authErrorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HelpingAppBar(
              title: isSettingPassword ? 'Set Password' : 'Change Password',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.authHorizontalMargin,
                  vertical: ScreenUtils.vMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSettingPassword) ...[
                      FieldLabel('Current Password'),
                      SizedBox(height: ScreenUtils.vSm),
                      AuthTextField(
                        hint: 'Enter current password',
                        obscureText: state.obscureCurrent,
                        onChanged: notifier.setCurrentPassword,
                        errorText: state.currentPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            state.obscureCurrent
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: ScreenUtils.iconSm,
                            color: AppColors.bodyText,
                          ),
                          onPressed: notifier.toggleObscureCurrent,
                        ),
                      ),
                      SizedBox(height: ScreenUtils.vMd),
                    ],

                    FieldLabel('New Password'),
                    SizedBox(height: ScreenUtils.vSm),
                    AuthTextField(
                      hint: 'Enter new password',
                      obscureText: state.obscureNew,
                      onChanged: notifier.setNewPassword,
                      errorText: state.newPasswordError,
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
                    SizedBox(height: 6.h),
                    Text(
                      'Must be 8+ characters with at least one uppercase letter and one number.',
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.bodyText,
                      ),
                    ),
                    SizedBox(height: ScreenUtils.vMd),

                    FieldLabel('Confirm New Password'),
                    SizedBox(height: ScreenUtils.vSm),
                    AuthTextField(
                      hint: 'Confirm new password',
                      obscureText: state.obscureConfirm,
                      onChanged: notifier.setConfirmPassword,
                      errorText: state.confirmPasswordError,
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: ScreenUtils.authHorizontalMargin,
                right: ScreenUtils.authHorizontalMargin,
                bottom: ScreenUtils.vXxl,
                top: ScreenUtils.vMd,
              ),
              child: PrimaryButton(
                label: isSettingPassword ? 'Set Password' : 'Update Password',
                isLoading: state.isLoading,
                onTap: () =>
                    notifier.submit(isSettingPassword: isSettingPassword),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
