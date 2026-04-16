import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onTryAgain;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.w,
      height: 242.h,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.md, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: ScreenUtils.iconMd,
            ),
          ),
          SizedBox(height: ScreenUtils.vMd),
          Text(
            title,
            style: AppTextStyles.labelLG.copyWith(color: AppColors.headingText),
          ),
          SizedBox(height: ScreenUtils.vSm),
          Text(
            message,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: ScreenUtils.buttonHeight,
            child: OutlinedButton(
              onPressed: onTryAgain,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                ),
              ),
              child: Text(
                'Try Again',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLG.copyWith(
                  color: AppColors.labelText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
