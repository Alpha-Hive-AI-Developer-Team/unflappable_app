import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/Create%20Password/create_passNotifier.dart';
import 'package:unflappable/features/provider/Auth/Create%20Password/create_passState.dart';

final createPasswordProvider =
    StateNotifierProvider.autoDispose<
      CreatePasswordNotifier,
      CreatePasswordState
    >((_) => CreatePasswordNotifier());
