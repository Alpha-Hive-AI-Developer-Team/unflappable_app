import 'package:flutter/material.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Stats',
          style: AppTextStyles.headingMD.copyWith(color: AppColors.headingText),
        ),
        SizedBox(height: ScreenUtils.vMd),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: ScreenUtils.md,
          crossAxisSpacing: ScreenUtils.md,
          children: [
            StatCard(
              icon: Icons.done_all_rounded,
              label: 'Day Streak',
              value: '00',
            ),
            StatCard(
              icon: Icons.favorite_outline,
              label: 'Missions',
              value: '00',
            ),
            StatCard(
              icon: Icons.run_circle_outlined,
              label: 'Run Record',
              value: 'Clear your mind',
            ),
            StatCard(
              icon: Icons.assessment_outlined,
              label: 'Weekly View',
              value: 'Reflect & plan',
            ),
          ],
        ),
      ],
    );
  }
}
