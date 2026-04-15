import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/export.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Setting/Widgets/shared_widgets.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';
import 'package:unflappable/features/widgets/Common/snackbar.dart';

class NotificationsSetting extends ConsumerWidget {
  const NotificationsSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final n = state.notifications;

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
                  // Daily Reminders toggle
                  ToggleRow(
                    label: 'Daily Reminders',
                    value: n.dailyReminders,
                    onChanged: notifier.toggleDailyReminders,
                  ),

                  SizedBox(height: 24.h),

                  // Morning Reminder
                  TimePickerRow(
                    label: 'Morning Reminder',
                    value: n.morningReminder,
                    onTap: () async {
                      final picked = await _pickTime(
                        context,
                        n.morningReminder,
                      );
                      if (picked != null) notifier.setMorningReminder(picked);
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Evening Reminder
                  TimePickerRow(
                    label: 'Evening Reminder',
                    value: n.eveningReminder,
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
                    onChanged: notifier.toggleWeeklyReview,
                  ),

                  SizedBox(height: 24.h),

                  // Weekly Reminder
                  TimePickerRow(
                    label: 'Weekly Reminder (${n.weeklyReminderDay})',
                    value: n.weeklyReminder,
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
