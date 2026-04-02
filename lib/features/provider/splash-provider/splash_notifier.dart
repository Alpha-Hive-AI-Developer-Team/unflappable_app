import 'package:flutter_riverpod/legacy.dart';

final splashProvider = StateNotifierProvider<SplashNotifier, bool>((ref) {
  return SplashNotifier();
});

class SplashNotifier extends StateNotifier<bool> {
  SplashNotifier() : super(false);

  bool _isNavigated = false;

  Future<void> navigateNext(void Function() onNavigate) async {
    if (_isNavigated) return;
    _isNavigated = true;

    await Future.delayed(const Duration(seconds: 3));

    onNavigate();
  }
}
