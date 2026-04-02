import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/splash-provider/splash_notifier.dart';

final splashProvider = StateNotifierProvider<SplashNotifier, bool>((ref) {
  return SplashNotifier();
});
