import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_notifier.dart';
import 'package:unflappable/features/Auth/login_screen/login_provider/login_state.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
      (_) => LoginNotifier(),
    );
