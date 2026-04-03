import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/forget_password/forget_password_provider/forget_passNotifier.dart';
import 'package:unflappable/features/Auth/forget_password/forget_password_provider/forget_passState.dart';

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<
      ForgotPasswordNotifier,
      ForgotPasswordState
    >((_) => ForgotPasswordNotifier());
