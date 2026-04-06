import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sami Perwaiz',
              style: AppTextStyles.headingLG.copyWith(
                color: AppColors.headingText,
              ),
            ),
            SizedBox(height: ScreenUtils.vSm),
            Text(
              'Welcome back',
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
            ),
          ],
        ),
        Icon(Icons.notifications_outlined, size: 28.r),
      ],
    );
  }
}
