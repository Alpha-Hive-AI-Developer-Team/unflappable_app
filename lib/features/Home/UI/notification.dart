import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Home/model/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.authHorizontalMargin,
                vertical: ScreenUtils.vMd,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: ScreenUtils.iconSm,
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(width: ScreenUtils.md),
                  Text(
                    'Notifications',
                    style: AppTextStyles.headingMD.copyWith(
                      color: AppColors.headingText,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.authHorizontalMargin,
                ),
                children: [
                  _SectionLabel('New'),
                  SizedBox(height: ScreenUtils.vSm),
                  ...newNotifications.map((n) => _NotificationTile(item: n)),

                  SizedBox(height: ScreenUtils.vMd),
                  _SectionLabel('Notifications'),
                  SizedBox(height: ScreenUtils.vSm),
                  ...oldNotifications.map((n) => _NotificationTile(item: n)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelMD.copyWith(color: AppColors.bodyText),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtils.vMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(ScreenUtils.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.labelMD.copyWith(
                            color: AppColors.headingText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        item.time,
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.body,
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
