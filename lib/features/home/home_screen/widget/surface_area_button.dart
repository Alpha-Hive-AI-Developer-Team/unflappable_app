import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class SurfaceAreaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SurfaceAreaButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.sm,
          vertical: ScreenUtils.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(ScreenUtils.radiusSm),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24.r),
            SizedBox(height: ScreenUtils.vSm),
            Text(
              label,
              style: AppTextStyles.bodySM.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
