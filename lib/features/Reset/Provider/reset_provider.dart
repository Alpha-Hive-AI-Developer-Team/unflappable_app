import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Reset/Provider/reset_notifier.dart';
import 'package:unflappable/features/Reset/Provider/reset_state.dart';

final resetProvider = StateNotifierProvider<ResetNotifier, ResetState>((ref) {
  ref.keepAlive();
  return ResetNotifier(ref: ref);
});
