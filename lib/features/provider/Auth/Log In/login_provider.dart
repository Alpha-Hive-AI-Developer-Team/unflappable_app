import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/Log%20In/login_notifier.dart';
import 'package:unflappable/features/provider/Auth/Log%20In/login_state.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
      (_) => LoginNotifier(),
    );
