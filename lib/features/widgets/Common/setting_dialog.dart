import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';

class SettingDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final VoidCallback onButton1;
  final String button1Text;
  final String purpose;

  const SettingDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onButton1,
    required this.button1Text,
    required this.purpose,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ScreenUtils.md, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: (purpose == "delete")
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.secondarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: (purpose == "delete")
                  ? AppColors.error
                  : AppColors.bodyText,
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
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.bodyText),
          ),
          SizedBox(height: ScreenUtils.vXl),
          purpose == 'delete'
              ? Column(
                  children: [
                    PrimaryButton(
                      label: button1Text,
                      isLoading: false,
                      onTap: onButton1,
                      backgroundColor: AppColors.error,
                    ),
                    SizedBox(height: ScreenUtils.vSm),
                    SizedBox(
                      width: double.infinity,
                      height: ScreenUtils.buttonHeight,
                      child: OutlinedButton(
                        onPressed: context.pop,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.borderGrey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ScreenUtils.radiusMd,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelLG.copyWith(
                            color: AppColors.labelText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: button1Text,
                        isLoading: false,
                        onTap: onButton1,
                        backgroundColor: AppColors.error,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.sm),
                    Expanded(
                      child: SizedBox(
                        height: ScreenUtils.buttonHeight,
                        child: OutlinedButton(
                          onPressed: context.pop,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.borderGrey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ScreenUtils.radiusMd,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.labelLG.copyWith(
                              color: AppColors.labelText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
