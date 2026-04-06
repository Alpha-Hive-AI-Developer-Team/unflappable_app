import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'surface_area_button.dart';

class SurfaceAreaSection extends StatelessWidget {
  const SurfaceAreaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Surface Area',
          style: AppTextStyles.headingMD.copyWith(color: AppColors.headingText),
        ),
        SizedBox(height: ScreenUtils.vMd),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenUtils.lg),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.aspect_ratio,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: ScreenUtils.md),
                  Text(
                    'Area Calculator',
                    style: AppTextStyles.labelLG.copyWith(
                      color: AppColors.headingText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtils.vMd),
              Text(
                'Calculate surface areas for different shapes',
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
              ),
              SizedBox(height: ScreenUtils.vMd),
              Row(
                children: [
                  Expanded(
                    child: SurfaceAreaButton(
                      icon: Icons.crop_square,
                      label: 'Square',
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: ScreenUtils.md),
                  Expanded(
                    child: SurfaceAreaButton(
                      icon: Icons.circle,
                      label: 'Circle',
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: ScreenUtils.md),
                  Expanded(
                    child: SurfaceAreaButton(
                      icon: Icons.change_history,
                      label: 'Triangle',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
