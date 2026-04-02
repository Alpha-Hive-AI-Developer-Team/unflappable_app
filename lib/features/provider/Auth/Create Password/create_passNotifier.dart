import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/Create%20Password/create_passState.dart';

class CreatePasswordNotifier extends StateNotifier<CreatePasswordState> {
  CreatePasswordNotifier() : super(const CreatePasswordState());

  void setNewPassword(String v) => state = state.copyWith(newPassword: v);
  void setConfirmPassword(String v) =>
      state = state.copyWith(confirmPassword: v);
  void toggleObscureNew() =>
      state = state.copyWith(obscureNew: !state.obscureNew);
  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    // TODO: call auth repository
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }
}
