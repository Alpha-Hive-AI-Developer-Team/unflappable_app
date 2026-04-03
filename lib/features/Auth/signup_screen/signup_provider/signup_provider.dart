import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_notifier.dart';
import 'package:unflappable/features/Auth/signup_screen/signup_provider/signup_state.dart';

final signUpProvider =
    StateNotifierProvider.autoDispose<SignUpNotifier, SignUpState>(
      (_) => SignUpNotifier(),
    );
