import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Notifications/notification_model.dart';
import 'package:unflappable/features/Notifications/notification_notifier.dart';
import 'package:unflappable/features/Notifications/notification_state.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationsProvider.notifier).fetchNotifications();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                  const Spacer(),
                  Text(
                    'Notifications',
                    style: AppTextStyles.headingMD.copyWith(
                      color: AppColors.headingText,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: state.notifications.isEmpty
                        ? null
                        : () => ref
                              .read(notificationsProvider.notifier)
                              .markAllAsRead(),
                    child: Text(
                      'Mark all read',
                      style: AppTextStyles.bodySM.copyWith(
                        color: state.notifications.isEmpty
                            ? AppColors.tertiaryText
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(notificationsProvider.notifier)
                      .fetchNotifications();
                },
                child: _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.authHorizontalMargin,
        ),
        children: [
          SizedBox(height: ScreenUtils.xxl),
          Text(
            state.errorMessage ?? 'Failed to load notifications.',
            style: AppTextStyles.bodySM.copyWith(color: AppColors.error),
          ),
        ],
      );
    }

    if (state.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtils.authHorizontalMargin,
        ),
        children: [
          SizedBox(height: ScreenUtils.xxl),
          Text(
            'No notifications yet.',
            style: AppTextStyles.bodySM.copyWith(color: AppColors.bodyText),
          ),
        ],
      );
    }

    final unread = state.notifications.where((item) => !item.isRead).toList();
    final read = state.notifications.where((item) => item.isRead).toList();

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.authHorizontalMargin,
        vertical: ScreenUtils.vSm,
      ),
      children: [
        if (unread.isNotEmpty) ...[
          _SectionLabel('New'),
          SizedBox(height: ScreenUtils.vSm),
          ...unread.map((item) => _NotificationTile(item: item)),
          SizedBox(height: ScreenUtils.vMd),
        ],
        _SectionLabel('Earlier'),
        SizedBox(height: ScreenUtils.vSm),
        ...read.map((item) => _NotificationTile(item: item)),
      ],
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

class _NotificationTile extends ConsumerWidget {
  final AppNotification item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtils.vMd),
      child: InkWell(
        onTap: () {
          ref.read(notificationsProvider.notifier).markAsRead(item.id);
        },
        child: Container(
          padding: EdgeInsets.all(ScreenUtils.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
            border: Border.all(
              color: item.isRead ? AppColors.borderGrey : AppColors.primary,
            ),
            color: item.isRead
                ? AppColors.secondarySurface
                : AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  if (!item.isRead)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtils.xs,
                        vertical: ScreenUtils.vXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          ScreenUtils.radiusSm,
                        ),
                      ),
                      child: Text(
                        'New',
                        style: AppTextStyles.bodySM.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                item.body,
                style: AppTextStyles.bodySM.copyWith(color: AppColors.bodyText),
              ),
              SizedBox(height: ScreenUtils.vSm),
              Text(
                item.receivedAt.toLocal().toString(),
                style: AppTextStyles.captionHint.copyWith(
                  color: AppColors.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
