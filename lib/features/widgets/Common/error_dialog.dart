import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onTryAgain;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onTryAgain,
    this.secondaryLabel,
    this.onSecondary,
  }) : assert(
          (secondaryLabel == null && onSecondary == null) ||
              (secondaryLabel != null && onSecondary != null),
          'secondaryLabel and onSecondary must both be set or both null.',
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentMaxH = constraints.maxHeight;
        final parentMaxW = constraints.maxWidth;

        const designDialogH = 242.0;
        const designDialogW = 400.0;

        final preferredH = designDialogH.h;
        final preferredW = designDialogW.w;

        // Keep original ~242×400 look; only shrink when a parent caps us (e.g. tight Stack).
        final dialogH = parentMaxH.isFinite && parentMaxH < double.infinity
            ? math.min(preferredH, parentMaxH)
            : preferredH;
        final dialogW = parentMaxW.isFinite && parentMaxW < double.infinity
            ? math.min(preferredW, parentMaxW)
            : preferredW;

        final squeezed = dialogH < preferredH - 1;

        return SizedBox(
          width: dialogW,
          height: dialogH,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtils.md,
              vertical: squeezed ? math.min(24.h, dialogH * 0.1) : 24.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.borderGrey),
              borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: ScreenUtils.iconMd,
                  ),
                ),
                SizedBox(height: squeezed ? math.min(ScreenUtils.vMd, dialogH * 0.04) : ScreenUtils.vMd),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLG.copyWith(
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: squeezed ? math.min(ScreenUtils.vSm, dialogH * 0.02) : ScreenUtils.vSm),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Text(
                      message,
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.bodyText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: squeezed ? math.min(ScreenUtils.vSm, dialogH * 0.02) : ScreenUtils.vSm),
                SizedBox(
                  width: double.infinity,
                  height: squeezed
                      ? math.min(
                          ScreenUtils.buttonHeight,
                          dialogH * 0.22,
                        ).clamp(40.0, ScreenUtils.buttonHeight)
                      : ScreenUtils.buttonHeight,
                  child: OutlinedButton(
                    onPressed: onTryAgain,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScreenUtils.radiusMd,
                        ),
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
                if (secondaryLabel != null && onSecondary != null) ...[
                  SizedBox(height: math.min(8.h, dialogH * 0.03)),
                  TextButton(
                    onPressed: onSecondary,
                    child: Text(
                      secondaryLabel!,
                      style: AppTextStyles.labelLG.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
