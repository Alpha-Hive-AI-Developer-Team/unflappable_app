import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

/// Extension to add consistent screen padding to any widget
extension ScreenPaddingExtension on Widget {
  /// Apply default screen padding (uses md for horizontal, vMd for vertical)
  Widget withScreenPadding({
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
    bool useSafeArea = true,
  }) {
    Widget padded = Padding(
      padding: EdgeInsets.only(
        left: left ?? horizontal ?? ScreenUtils.lg,
        right: right ?? horizontal ?? ScreenUtils.lg,
        top: top ?? vertical ?? 24.h,
        bottom: bottom ?? vertical ?? 24.h,
      ),
      child: this,
    );

    if (useSafeArea) {
      padded = SafeArea(child: padded);
    }

    return padded;
  }

  /// Apply horizontal padding only
  Widget withHorizontalPadding({double? padding}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? ScreenUtils.md),
      child: this,
    );
  }

  /// Apply vertical padding only
  Widget withVerticalPadding({double? padding}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding ?? ScreenUtils.vMd),
      child: this,
    );
  }

  /// Apply specific side padding
  Widget withPadding({
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left ?? 0,
        right: right ?? 0,
        top: top ?? 0,
        bottom: bottom ?? 0,
      ),
      child: this,
    );
  }

  /// Apply auth screen specific padding
  Widget withAuthScreenPadding() {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtils.authHorizontalMargin,
        right: ScreenUtils.authHorizontalMargin,
        top: ScreenUtils.authTopMargin,
        bottom: ScreenUtils.authBottomMargin,
      ),
      child: this,
    );
  }
}
