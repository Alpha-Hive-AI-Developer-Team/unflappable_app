import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Reset/Provider/reset_notifier.dart';
import 'package:unflappable/features/Reset/Provider/reset_state.dart';

final resetProvider = StateNotifierProvider<ResetNotifier, ResetState>((ref) {
  return ResetNotifier();
});
