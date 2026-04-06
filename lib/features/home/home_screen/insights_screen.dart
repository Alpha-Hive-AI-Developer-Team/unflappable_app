import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
                Icons.insights,
                size: 64.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: ScreenUtils.vXxl),
            Text(
              'Your Insights',
              style: AppTextStyles.headingLG
                  .copyWith(color: AppColors.headingText),
            ),
            SizedBox(height: ScreenUtils.vMd),
            Text(
              'Track your progress and get personalized insights',
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
                    'This Week',
                    style: AppTextStyles.labelMD
                        .copyWith(color: AppColors.headingText),
                  ),
                  SizedBox(height: ScreenUtils.vMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      7,
                      (index) => Column(
                        children: [
                          Container(
                            height: 40.h,
                            width: 30.w,
                            decoration: BoxDecoration(
                              color: index < 3
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(ScreenUtils.radiusSm),
                            ),
                          ),
                          SizedBox(height: ScreenUtils.vSm),
                          Text(
                            _getDayLabel(index),
                            style: AppTextStyles.bodySM
                                .copyWith(color: AppColors.bodyText),
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

  String _getDayLabel(int index) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[index];
  }
}
