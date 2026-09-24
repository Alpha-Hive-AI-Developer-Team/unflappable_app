import 'package:flutter_riverpod/flutter_riverpod.dart';
// PRO FEATURE — disabled for the current free-only release.
// import 'package:unflappable/features/Pricing/Provider/pricing_notifier.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_notifier.dart';
import 'package:unflappable/features/Mission%20History/missionHistory_notifier.dart';
import 'package:unflappable/features/Notifications/notification_notifier.dart';
import 'package:unflappable/features/Reset/Provider/reset_provider.dart';
import 'package:unflappable/features/Setting/Provider/setting_notifier.dart';
import 'package:unflappable/features/Weekly%20Review/Provider/review_notifier.dart';

void resetSessionScopedProviders(WidgetRef ref) {
  // PRO FEATURE — disabled for the current free-only release.
  // ref.invalidate(pricingPlansProvider);
  ref.invalidate(homeProvider);
  ref.invalidate(resetProvider);
  ref.invalidate(settingsProvider);
  ref.invalidate(weeklyReviewProvider);
  ref.invalidate(missionHistoryProvider);
  ref.invalidate(notificationsProvider);
}

/// Same invalidations as [resetSessionScopedProviders], for use outside widgets.
void invalidateSessionScopedProviders(ProviderContainer container) {
  // PRO FEATURE — disabled for the current free-only release.
  // container.invalidate(pricingPlansProvider);
  container.invalidate(homeProvider);
  container.invalidate(resetProvider);
  container.invalidate(settingsProvider);
  container.invalidate(weeklyReviewProvider);
  container.invalidate(missionHistoryProvider);
  container.invalidate(notificationsProvider);
}
