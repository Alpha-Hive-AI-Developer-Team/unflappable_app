import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onTap,
  });

  // Figma shadows translated to Flutter BoxShadow
  static const _shadows = [
    BoxShadow(
      color: Color(0x0D000000), // #0000000D
      offset: Offset(1, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // #0000000A
      offset: Offset(3, 5),
      blurRadius: 5,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000), // #00000008
      offset: Offset(7, 10),
      blurRadius: 7,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x03000000), // #00000003
      offset: Offset(12, 18),
      blurRadius: 9,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(
        0x00000000,
      ), // #00000000 — fully transparent, no visual effect
      offset: Offset(18, 28),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(ScreenUtils.radiusMd);
    final isDisabled = onTap == null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: isDisabled ? null : _shadows, // no shadow when disabled
      ),
      child: SizedBox(
        width: double.infinity,
        height: ScreenUtils.buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style:
              ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? AppColors.borderGrey
                    : AppColors.primary,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.borderGrey,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
              ).copyWith(
                // Inset white glow — applied via overlayColor trick using a
                // custom ButtonStyle so we can paint it as a foreground layer
                backgroundBuilder: (context, states, child) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: isDisabled
                          ? null
                          : const LinearGradient(
                              // keeps the solid blue base; the inset glow sits on top
                              colors: [AppColors.primary, AppColors.primary],
                            ),
                    ),
                    child: DecoratedBox(
                      // inset: 0px 0px 24px 0px #FFFFFF80
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        boxShadow: isDisabled
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x80FFFFFF),
                                  offset: Offset(0, 0),
                                  blurRadius: 24,
                                  spreadRadius: 0,
                                  // Flutter doesn't support CSS `inset` natively,
                                  // but blurStyle: BlurStyle.inner approximates it
                                  blurStyle: BlurStyle.inner,
                                ),
                              ],
                      ),
                      child: child,
                    ),
                  );
                },
              ),
          child: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.buttonLG.copyWith(
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
// ── Secondary (outline) Button ────────────────────────────────────────────────

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SecondaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtils.buttonHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.borderGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLG.copyWith(color: AppColors.headingText),
        ),
      ),
    );
  }
}
