import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/app_strings.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_notifier.dart';
import 'package:unflappable/features/Home/UI/stat_card.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/widgets/Common/app_header.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);

    if (!state.hasLoaded && !state.isLoading) {
      Future.microtask(() => notifier.loadHome());
    }

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
              mainText: state.taskCompletionLabel,
              icon: completion,
              subText: state.taskCompletionSubtitle,
              completionRate: state.taskCompletionPercentage,
            ),
            SizedBox(height: ScreenUtils.vMd),
            _performanceCard(
              mainText: state.totalResetsLabel,
              icon: refresh,
              subText: state.totalResetsSubtitle,
              completionRate: state.totalResets.toDouble(),
              isPercent: false,
            ),
            SizedBox(height: ScreenUtils.vMd),
            _performanceCard(
              mainText: "Mission History",
              icon: history,
              onTap: () => context.push(AppRoutes.mission_history),
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
  final String? subText;
  final double? completionRate;
  final void Function()? onTap;
  final bool isPercent;

  const _performanceCard({
    required this.mainText,
    required this.icon,
    this.subText,
    this.completionRate,
    this.onTap,
    this.isPercent = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                subText != null
                    ? Text(
                        subText!,
                        style: AppTextStyles.bodyLG.copyWith(
                          color: AppColors.bodyText,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            const Spacer(),
            completionRate != null
                ? Text(
                    isPercent
                        ? '${(completionRate! * 100).round()}%'
                        : completionRate!.toStringAsFixed(0),
                    style: AppTextStyles.bodyLG.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
