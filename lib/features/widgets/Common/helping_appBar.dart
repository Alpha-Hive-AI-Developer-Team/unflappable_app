import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class HelpingAppBar extends StatelessWidget {
  final String title;
  const HelpingAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenUtils.authHorizontalMargin,
        ScreenUtils.vMd,
        ScreenUtils.authHorizontalMargin,
        ScreenUtils.vXl,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button (left aligned)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: ScreenUtils.iconSm,
                color: AppColors.headingText,
              ),
            ),
          ),

          // Centered Title
          Center(
            child: Text(
              title,
              style: AppTextStyles.headingLG.copyWith(
                color: AppColors.headingText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
