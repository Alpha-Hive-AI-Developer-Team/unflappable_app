import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_notifier.dart';
import 'package:unflappable/features/Home/UI/stat_card.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/widgets/Common/app_header.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: ScreenUtils.vMd,
          bottom: 8.h + 65.h + 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'Progress',
              subtitle: 'Track your consistency and focus.',
            ),
            SizedBox(height: ScreenUtils.vMd),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    type: StatCardType.streak,
                    count: state.dayStreak,
                  ),
                ),
                SizedBox(width: ScreenUtils.md),
                Expanded(
                  child: StatCard(
                    type: StatCardType.missions,
                    count: state.missionCount,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.vLg),
            Text(
              'Performance Stats',
              style: AppTextStyles.headingSM.copyWith(
                color: AppColors.headingText,
              ),
            ),
            SizedBox(height: ScreenUtils.vMd),
            _performanceCard(
              mainText: 'Task Completion',
              icon: completion,
              subText:
                  ' ${state.completedTasks} of ${state.totalTasks} tasks done',
              completionRate: state.completionRate,
            ),
            SizedBox(height: ScreenUtils.vMd),
            _performanceCard(
              mainText: 'Total Resets',
              icon: refresh,
              subText: ' Moment of recovery',
              completionRate: 0.02,
            ),
          ],
        ),
      ),
    );
  }
}

class _performanceCard extends StatelessWidget {
  final String mainText;
  final String icon;
  final String subText;
  final double completionRate;

  const _performanceCard({
    required this.mainText,
    required this.icon,
    required this.subText,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.md),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 32.w, height: 32.w),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainText,
                style: AppTextStyles.headingSM.copyWith(
                  color: AppColors.headingText,
                ),
              ),
              Text(
                subText,
                style: AppTextStyles.bodyLG.copyWith(color: AppColors.bodyText),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${(completionRate * 100).round()}%',
            style: AppTextStyles.bodyLG.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
