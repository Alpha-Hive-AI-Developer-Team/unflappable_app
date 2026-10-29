import 'package:flutter/material.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AppHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // UA-12: truncate rather than overflow/wrap awkwardly — guards
        // against a long display name (legacy data, Apple-derived, etc.)
        // breaking whatever row this header sits in.
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headingLG.copyWith(color: AppColors.headingText),
        ),
        SizedBox(height: ScreenUtils.vSm),
        Text(
          subtitle,
          style: AppTextStyles.bodyLG.copyWith(color: AppColors.bodyText),
        ),
      ],
    );
  }
}
