import 'dart:ui';

import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Setting/Widgets/shared_widgets.dart';
import 'package:unflappable/features/widgets/Common/setting_dialog.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isPro = userState.isPro;

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
                  notifier.initAccountDraft(
                    name: userState.userName,
                    email: userState.userEmail,
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
                    barrierColor: Colors.black.withOpacity(0.2), // dim effect
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
                            onButton1: () {
                              context.pop();
                              ref.read(userProvider.notifier).clearUser();
                              AppSnackbar.showSuccess(
                                context,
                                message: "Logged out successfully.",
                              );
                              context.go(AppRoutes.login);
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
                              context.pop();
                              ref.read(userProvider.notifier).clearUser();
                              AppSnackbar.showSuccess(
                                context,
                                message: "Account deleted successfully.",
                              );
                              context.go(AppRoutes.login);
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
}
