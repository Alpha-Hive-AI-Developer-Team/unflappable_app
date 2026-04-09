import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Setting/Model/legal_model.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HelpingAppBar(title: 'Legal'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.authHorizontalMargin,
                  vertical: ScreenUtils.vMd,
                ),
                child: Column(
                  children: [
                    _LegalTile(
                      icon: Icons.warning_amber_outlined,
                      label: 'Privacy Policy',
                      onTap: () {
                        context.push(
                          AppRoutes.privacyPolicy,
                          extra: PolicyScreenArgs(
                            title: 'Privacy Policy',
                            lastUpdated: 'September 1, 2023',
                            sections: privacyPolicySections,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: ScreenUtils.vMd),
                    _LegalTile(
                      icon: Icons.description_outlined,
                      label: 'Terms of Use',
                      onTap: () {
                        context.push(
                          AppRoutes.privacyPolicy,
                          extra: PolicyScreenArgs(
                            title: 'Terms of Use',
                            lastUpdated: 'September 1, 2023',
                            sections: termsOfUseSections,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LegalTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.md,
          vertical: ScreenUtils.vMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
              ),
              child: Icon(
                icon,
                size: ScreenUtils.iconMd,
                color: AppColors.headingText,
              ),
            ),
            SizedBox(width: ScreenUtils.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.headingText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: ScreenUtils.iconMd,
              color: AppColors.bodyText,
            ),
          ],
        ),
      ),
    );
  }
}
