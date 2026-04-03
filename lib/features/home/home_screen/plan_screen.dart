import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

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
                Icons.edit_note_outlined,
                size: 64.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: ScreenUtils.vXxl),
            Text(
              'Create Your Plan',
              style: AppTextStyles.headingLG
                  .copyWith(color: AppColors.headingText),
            ),
            SizedBox(height: ScreenUtils.vMd),
            Text(
              'Clear your mind and plan your day',
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
                    'Today\'s Tasks',
                    style: AppTextStyles.labelMD
                        .copyWith(color: AppColors.headingText),
                  ),
                  SizedBox(height: ScreenUtils.vMd),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: ScreenUtils.md),
                      child: Row(
                        children: [
                          Checkbox(
                            value: index == 0,
                            onChanged: (value) {},
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: Text(
                              'Task ${index + 1}',
                              style: AppTextStyles.bodyMD.copyWith(
                                color: AppColors.headingText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtils.vMd),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
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
}
