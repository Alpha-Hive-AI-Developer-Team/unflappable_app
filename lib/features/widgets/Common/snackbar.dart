import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/core/theme/app_colors.dart';

enum SnackbarType { success, error }

class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      type: SnackbarType.success,
      message: message,
      title: title,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      type: SnackbarType.error,
      message: message,
      title: title,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required SnackbarType type,
    required String message,
    String? title,
    required Duration duration,
  }) {
    // Remove any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        margin: EdgeInsets.only(
          left: ScreenUtils.authHorizontalMargin,
          right: ScreenUtils.authHorizontalMargin,
          bottom: 24.h,
        ),
        content: _AppSnackbarContent(
          type: type,
          title: title,
          message: message,
        ),
      ),
    );
  }
}

class _AppSnackbarContent extends StatelessWidget {
  final SnackbarType type;
  final String? title;
  final String message;

  const _AppSnackbarContent({
    required this.type,
    this.title,
    required this.message,
  });

  bool get _isSuccess => type == SnackbarType.success;

  Color get _bgColor =>
      _isSuccess ? const Color(0xFFEDFBF1) : const Color(0xFFFFF0F0);

  Color get _borderColor =>
      _isSuccess ? const Color(0xFF34C759) : AppColors.error;

  Color get _iconBgColor =>
      _isSuccess ? const Color(0xFF34C759) : AppColors.error;

  Color get _titleColor =>
      _isSuccess ? const Color(0xFF1A7A35) : AppColors.error;

  IconData get _icon => _isSuccess ? Icons.check_rounded : Icons.close_rounded;

  String get _defaultTitle => _isSuccess ? 'Success' : 'Error';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.md,
        vertical: ScreenUtils.vMd,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
        border: Border.all(color: _borderColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: _borderColor.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: _iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: AppColors.white, size: 18.w),
          ),

          SizedBox(width: ScreenUtils.md),

          // Title + message
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? _defaultTitle,
                  style: AppTextStyles.labelMD.copyWith(color: _titleColor),
                ),
                if (message.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    message,
                    style: AppTextStyles.bodySM.copyWith(
                      color: _titleColor.withOpacity(0.75),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: ScreenUtils.sm),

          // Dismiss button
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: Icon(
              Icons.close_rounded,
              size: ScreenUtils.iconSm,
              color: _titleColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
