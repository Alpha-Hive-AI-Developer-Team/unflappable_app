import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_notifier.dart';
import 'package:unflappable/features/Mission%20History/missionHistory_notifier.dart';
import 'package:unflappable/features/Notifications/notification_notifier.dart';
import 'package:unflappable/features/Reset/Provider/reset_provider.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Weekly%20Review/Provider/review_notifier.dart';

void resetSessionScopedProviders(WidgetRef ref) {
  ref.invalidate(homeProvider);
  ref.invalidate(resetProvider);
  ref.invalidate(settingsProvider);
  ref.invalidate(weeklyReviewProvider);
  ref.invalidate(missionHistoryProvider);
  ref.invalidate(notificationsProvider);
}
