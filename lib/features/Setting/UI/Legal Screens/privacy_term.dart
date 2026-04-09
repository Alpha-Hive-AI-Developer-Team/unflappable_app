import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Setting/Model/legal_model.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

class PolicyScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<PolicySection> sections;

  const PolicyScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            HelpingAppBar(title: title),

            SizedBox(height: ScreenUtils.vLg),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  left: ScreenUtils.authHorizontalMargin,
                  right: ScreenUtils.authHorizontalMargin,
                  bottom: 32.h,
                ),
                children: [
                  // Last updated
                  Text(
                    'Last updated: $lastUpdated',
                    style: AppTextStyles.bodyLG.copyWith(
                      color: AppColors.bodyText,
                    ),
                  ),

                  SizedBox(height: ScreenUtils.vMd),

                  // Sections
                  ...sections.map((s) => _PolicySectionWidget(section: s)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POLICY SECTION WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _PolicySectionWidget extends StatelessWidget {
  final PolicySection section;
  const _PolicySectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtils.vLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: AppTextStyles.bodyLG.copyWith(
              color: AppColors.headingText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ScreenUtils.vSm),
          Text(
            section.body,
            style: AppTextStyles.bodyLG.copyWith(color: AppColors.setting_text),
          ),
        ],
      ),
    );
  }
}
