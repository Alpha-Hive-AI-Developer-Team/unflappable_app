import 'dart:ui';

import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Setting/Widgets/shared_widgets.dart';
import 'package:unflappable/features/navbar_wrapper/home_shell.dart';
import 'package:unflappable/features/widgets/Common/setting_dialog.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenContext = context;
    final userState = ref.watch(userProvider);
    final settingsState = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isPro = userState.isPro;
    if (!settingsState.hasLoadedInitialData &&
        !settingsState.isLoadingInitialData) {
      Future.microtask(notifier.loadInitialData);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.authHorizontalMargin,
            vertical: ScreenUtils.authBottomMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppHeader(title: 'Settings', subtitle: userState.userEmail),

              SizedBox(height: ScreenUtils.vXl),

              // ── Subscription ────────────────────────────────────────────
              SectionLabel('Subscription'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.md,
                  vertical: ScreenUtils.vMd,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(ScreenUtils.sm),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: AppColors.primary,
                      size: ScreenUtils.iconLg,
                    ),
                    SizedBox(width: ScreenUtils.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPro ? 'Pro Plan' : 'Free Plan',
                            style: AppTextStyles.labelLG.copyWith(
                              color: AppColors.headingText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            isPro ? 'Active' : 'Upgrade for more',
                            style: AppTextStyles.bodyMD.copyWith(
                              color: AppColors.bodyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 50.w),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Manage',
                        isLoading: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ScreenUtils.vXl),

              // ── Preferences ─────────────────────────────────────────────
              SectionLabel('Preferences'),
              SizedBox(height: ScreenUtils.vSm),
              SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => context.push(AppRoutes.notificationSetting),
              ),
              SizedBox(height: ScreenUtils.vSm),
              SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Account',
                onTap: () {
                  final account = ref.read(settingsProvider).accountDraft;
                  notifier.initAccountDraft(
                    name: account.fullName.isNotEmpty
                        ? account.fullName
                        : userState.userName,
                    email: account.email.isNotEmpty
                        ? account.email
                        : userState.userEmail,
                  );
                  context.push(AppRoutes.account);
                },
              ),

              SizedBox(height: ScreenUtils.vXl),

              // ── Support ─────────────────────────────────────────────────
              SectionLabel('Support'),
              SizedBox(height: ScreenUtils.vSm),
              SettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Help Center',
                onTap: () => context.push(AppRoutes.helpCenter),
              ),
              SizedBox(height: ScreenUtils.vSm),
              SettingsTile(
                icon: Icons.warning_amber_outlined,
                label: 'Legal',
                onTap: () => context.push(AppRoutes.legal),
              ),
              SizedBox(height: 24.h),
              SettingsTile(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.2),
                    builder: (context) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Dialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          backgroundColor: Colors.transparent,
                          child: SettingDialog(
                            title: "Logout",
                            message: "Are you sure you want to log out?",
                            button1Text: "Logout",
                            purpose: "logout",
                            icon: Icons.logout_outlined,
                            onButton1: () async {
                              Navigator.of(context).pop();
                              final success = await notifier.logout();
                              if (!screenContext.mounted) return;
                              if (!success) {
                                final latest = ref.read(settingsProvider);
                                AppSnackbar.showError(
                                  screenContext,
                                  message:
                                      latest.errorMessage ??
                                      "Unable to logout right now.",
                                );
                                return;
                              }
                              ref.read(navIndexProvider.notifier).state = 0;
                              ref.read(userProvider.notifier).clearUser();
                              AppSnackbar.showSuccess(
                                screenContext,
                                message: "Logged out successfully.",
                              );
                              screenContext.go(AppRoutes.login);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: ScreenUtils.vMd),

              // Delete Account — red
              SettingsTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Account',
                labelColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.2), // dim effect
                    builder: (context) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Dialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          backgroundColor: Colors.transparent,
                          child: SettingDialog(
                            title: "Are you absolutely sure?",
                            message:
                                "This action cannot be undone. This will permanently delete your account and remove your data from our servers.",
                            button1Text: "Yes, delete my account",
                            purpose: "delete",
                            icon: Icons.warning_amber_outlined,
                            onButton1: () {
                              Navigator.of(context).pop();
                              _showDeleteAccountDialog(screenContext, ref);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final screenContext = context;
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final notifier = ref.read(settingsProvider.notifier);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: ScreenUtils.md),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.md,
              vertical: 24.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.borderGrey),
              borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: ScreenUtils.iconMd,
                  ),
                ),
                SizedBox(height: ScreenUtils.vMd),

                // Title
                Text(
                  'Delete Account',
                  style: AppTextStyles.labelLG.copyWith(
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: ScreenUtils.vSm),

                // Subtitle message
                Text(
                  'Enter your password and type DELETE MY ACCOUNT to confirm.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: ScreenUtils.vMd),

                // Password field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.headingText,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.bodyText,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                      borderSide: BorderSide(color: AppColors.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtils.vMd),

                // Confirmation text field
                TextField(
                  controller: confirmController,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.headingText,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Confirmation text',
                    hintText: 'DELETE MY ACCOUNT',
                    hintStyle: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.bodyText.withOpacity(0.5),
                    ),
                    labelStyle: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.bodyText,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                      borderSide: BorderSide(color: AppColors.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtils.vXl),

                // Delete button
                PrimaryButton(
                  label: 'Delete Account',
                  isLoading: false,
                  onTap: () async {
                    final password = passwordController.text.trim();
                    final confirmText = confirmController.text.trim();

                    if (password.isEmpty || confirmText.isEmpty) {
                      AppSnackbar.showError(
                        context,
                        message: 'Both fields are required.',
                      );
                      return;
                    }

                    final success = await notifier.deleteAccount(
                      password: password,
                      confirmText: confirmText,
                    );
                    if (!screenContext.mounted) return;
                    if (!success) {
                      final latest = ref.read(settingsProvider);
                      AppSnackbar.showError(
                        screenContext,
                        message:
                            latest.errorMessage ??
                            "Unable to delete account right now.",
                      );
                      return;
                    }

                    ref.read(navIndexProvider.notifier).state = 0;
                    Navigator.of(dialogContext).pop();
                    ref.read(userProvider.notifier).clearUser();
                    AppSnackbar.showSuccess(
                      screenContext,
                      message: "Account deleted successfully.",
                    );
                    screenContext.go(AppRoutes.login);
                  },
                  backgroundColor: AppColors.error,
                ),
                SizedBox(height: ScreenUtils.vSm),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: ScreenUtils.buttonHeight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScreenUtils.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLG.copyWith(
                        color: AppColors.labelText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
