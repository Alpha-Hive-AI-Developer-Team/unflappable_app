import 'package:unflappable/core/notifications/notification_manager.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Setting/Widgets/shared_widgets.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class NotificationsSetting extends ConsumerStatefulWidget {
  const NotificationsSetting({super.key});

  @override
  ConsumerState<NotificationsSetting> createState() =>
      _NotificationsSettingState();
}

class _NotificationsSettingState extends ConsumerState<NotificationsSetting> {
  bool? _osPermissionGranted;

  @override
  void initState() {
    super.initState();
    NotificationManager.hasPermission().then((granted) {
      if (mounted) setState(() => _osPermissionGranted = granted);
    });
    // US-70 / US-24: always re-pull the saved preferences on entry so a
    // previous visit's unsaved edits (or stale cached state) can never be
    // shown in place of what's actually saved server-side.
    ref.read(settingsProvider.notifier).loadInitialData(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final n = state.notifications;
    // US-68: a toggle can be saved ON from a previous session while the OS
    // permission is actually off (revoked in system settings, fresh
    // install restoring old prefs, etc.) — don't let the UI silently imply
    // reminders are active in that case.
    final showPermissionWarning =
        _osPermissionGranted == false && (n.dailyReminders || n.weeklyReview);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            HelpingAppBar(title: 'Notifications'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.authHorizontalMargin,
                  vertical: ScreenUtils.vLg,
                ),
                children: [
                  if (showPermissionWarning) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ScreenUtils.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                          ScreenUtils.radiusSm,
                        ),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.error,
                            size: ScreenUtils.iconMd,
                          ),
                          SizedBox(width: ScreenUtils.sm),
                          Expanded(
                            child: Text(
                              'Notifications are turned off at the system '
                              'level, so these reminders won\'t actually be '
                              'delivered until you re-enable the permission.',
                              style: AppTextStyles.bodySM.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.vMd),
                  ],

                  // Daily Reminders toggle
                  ToggleRow(
                    label: 'Daily Reminders',
                    value: n.dailyReminders,
                    onChanged: (v) async {
                      // Request notification permission at this relevant
                      // moment (the user is explicitly asking for a
                      // reminder) rather than unconditionally at app launch.
                      if (v) {
                        final granted =
                            await NotificationManager.requestPermissions();
                        if (mounted) {
                          setState(() => _osPermissionGranted = granted);
                        }
                        if (!granted) {
                          // US-68: don't leave the toggle showing ON when
                          // permission was actually denied/dismissed.
                          notifier.toggleDailyReminders(false);
                          if (context.mounted) {
                            AppSnackbar.showError(
                              context,
                              message:
                                  'Notifications permission is required for reminders.',
                            );
                          }
                          return;
                        }
                      }
                      notifier.toggleDailyReminders(v);
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Morning Reminder — the cron only reads the single
                  // `dailyReminders` flag (morning + evening share it), so
                  // disable the time pickers when it's off to avoid implying
                  // they can be controlled independently.
                  TimePickerRow(
                    label: 'Morning Reminder',
                    value: n.morningReminder,
                    enabled: n.dailyReminders,
                    onTap: () async {
                      final picked = await _pickTime(
                        context,
                        n.morningReminder,
                      );
                      if (picked != null) notifier.setMorningReminder(picked);
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Evening Reminder — shares `dailyReminders` with Morning.
                  TimePickerRow(
                    label: 'Evening Reminder',
                    value: n.eveningReminder,
                    enabled: n.dailyReminders,
                    onTap: () async {
                      final picked = await _pickTime(
                        context,
                        n.eveningReminder,
                      );
                      if (picked != null) notifier.setEveningReminder(picked);
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Weekly Review toggle
                  ToggleRow(
                    label: 'Weekly Review',
                    value: n.weeklyReview,
                    onChanged: (v) async {
                      if (v) {
                        final granted =
                            await NotificationManager.requestPermissions();
                        if (mounted) {
                          setState(() => _osPermissionGranted = granted);
                        }
                        if (!granted) {
                          notifier.toggleWeeklyReview(false);
                          if (context.mounted) {
                            AppSnackbar.showError(
                              context,
                              message:
                                  'Notifications permission is required for reminders.',
                            );
                          }
                          return;
                        }
                      }
                      notifier.toggleWeeklyReview(v);
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Weekly Reminder — gated by the `weeklyReview` flag.
                  TimePickerRow(
                    label: 'Weekly Reminder (${n.weeklyReminderDay})',
                    value: n.weeklyReminder,
                    enabled: n.weeklyReview,
                    onTap: () async {
                      final picked = await _pickTime(context, n.weeklyReminder);
                      if (picked != null) notifier.setWeeklyReminder(picked);
                    },
                  ),
                  SizedBox(height: ScreenUtils.vXl),
                  PrimaryButton(
                    label: 'Save Preferences',
                    isLoading: state.isSavingNotifications,
                    onTap: () async {
                      await notifier.saveNotifications();
                      if (!context.mounted) return;
                      final latest = ref.read(settingsProvider);
                      if (latest.errorMessage != null) {
                        AppSnackbar.showError(
                          context,
                          message: latest.errorMessage!,
                        );
                        return;
                      }
                      AppSnackbar.showSuccess(
                        context,
                        message: 'Notification preferences updated.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    // Parse current string to TimeOfDay
    final parts = current
        .replaceAll(' AM', '')
        .replaceAll(' PM', '')
        .split(':');
    final isPM = current.contains('PM');
    var hour = int.tryParse(parts[0]) ?? 8;
    final min = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: min),
    );
    if (picked == null) return null;
    return picked.format(context);
  }
}
