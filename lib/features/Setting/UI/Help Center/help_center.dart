import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HelpingAppBar(title: 'Help Center'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.authHorizontalMargin,
                  vertical: ScreenUtils.vMd,
                ),
                child: Column(
                  children: [
                    _HelpTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Live Chat',
                      subtitle: 'Typically replies in 5 mins',
                      onTap: () {},
                    ),
                    SizedBox(height: ScreenUtils.vMd),
                    _HelpTile(
                      icon: Icons.email_outlined,
                      label: 'Email Support',
                      subtitle: 'support@framt.com',
                      onTap: () {},
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

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.label,
    required this.subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelLG.copyWith(
                      color: AppColors.headingText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelMD.copyWith(
                      color: AppColors.bodyText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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
