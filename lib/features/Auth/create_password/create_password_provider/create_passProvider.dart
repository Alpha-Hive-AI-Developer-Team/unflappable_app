
import '../create_password_export.dart';

final createPasswordProvider =
    StateNotifierProvider.autoDispose<
      CreatePasswordNotifier,
      CreatePasswordState
    >((_) => CreatePasswordNotifier());
