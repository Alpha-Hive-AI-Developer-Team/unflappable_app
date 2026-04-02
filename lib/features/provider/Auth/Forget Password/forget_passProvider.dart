import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/Forget%20Password/forget_passNotifier.dart';
import 'package:unflappable/features/provider/Auth/Forget%20Password/forget_passState.dart';

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<
      ForgotPasswordNotifier,
      ForgotPasswordState
    >((_) => ForgotPasswordNotifier());
