import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/Sign%20Up/signup_notifier.dart';
import 'package:unflappable/features/provider/Auth/Sign%20Up/signup_state.dart';

final signUpProvider =
    StateNotifierProvider.autoDispose<SignUpNotifier, SignUpState>(
      (_) => SignUpNotifier(),
    );
