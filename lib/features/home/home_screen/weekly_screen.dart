import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 64.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: ScreenUtils.vXxl),
            Text(
              'Weekly View',
              style: AppTextStyles.headingLG
                  .copyWith(color: AppColors.headingText),
            ),
            SizedBox(height: ScreenUtils.vMd),
            Text(
              'Reflect & plan your week ahead',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: ScreenUtils.vXxl),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenUtils.lg),
              decoration: BoxDecoration(
                color: AppColors.secondarySurface,
                borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week\'s Summary',
                    style: AppTextStyles.labelMD
                        .copyWith(color: AppColors.headingText),
                  ),
                  SizedBox(height: ScreenUtils.vMd),
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: ScreenUtils.md),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20.r,
                          ),
                          SizedBox(width: ScreenUtils.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Activity on ${_getDayName(index)}',
                                  style: AppTextStyles.labelMD
                                      .copyWith(color: AppColors.headingText),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '5 tasks completed',
                                  style: AppTextStyles.bodySM
                                      .copyWith(color: AppColors.bodyText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int index) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday'];
    return days[index];
  }
}
