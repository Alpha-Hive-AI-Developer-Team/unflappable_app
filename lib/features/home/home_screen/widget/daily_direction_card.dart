import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class DailyDirectionCard extends StatelessWidget {
  const DailyDirectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtils.lg),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/backgroud.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: ScreenUtils.vMd),
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 26.r),
          ),
          SizedBox(height: ScreenUtils.vMd),
          Text(
            'Get Daily Direction',
            style: AppTextStyles.headingMD.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          SizedBox(height: ScreenUtils.vSm),
          Text(
            'Set clear goals and write them for today',
            style: AppTextStyles.bodyMD.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          // SizedBox(height: ScreenUtils.vMd),
          // ElevatedButton(
          //   onPressed: () {},
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.white,
          //     foregroundColor: AppColors.primary,
          //     padding: EdgeInsets.symmetric(
          //       horizontal: ScreenUtils.md,
          //       vertical: ScreenUtils.sm,
          //     ),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
          //     ),
          //   ),
          //   child: Text(
          //     'Start Now',
          //     style: AppTextStyles.labelMD.copyWith(
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
