import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/navigation/root_navigator_key.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/core/utils/session_provider_reset.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';

bool _handlingUserNotFound401 = false;

bool _responseIsUserNotFound401(DioException e) {
  if (e.response?.statusCode != 401) return false;
  final data = e.response?.data;
  if (data is! Map) return false;
  final msg = data['message'];
  if (msg is! String) return false;
  return msg.trim().toLowerCase() == 'user not found';
}

/// Clears stored session and sends the user to login when the API reports
/// the JWT user id no longer exists (e.g. DB reset, wrong environment).
void _scheduleForceLogin() {
  if (_handlingUserNotFound401) return;
  _handlingUserNotFound401 = true;

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await LocalStorage.clearAllData();
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        final container = ProviderScope.containerOf(ctx, listen: false);
        container.read(userProvider.notifier).clearUser();
        invalidateSessionScopedProviders(container);
        GoRouter.of(ctx).go(AppRoutes.login);
      }
    } finally {
      Future<void>.delayed(const Duration(seconds: 1), () {
        _handlingUserNotFound401 = false;
      });
    }
  });
}

final Interceptor userNotFound401Interceptor = InterceptorsWrapper(
  onError: (DioException error, ErrorInterceptorHandler handler) {
    if (_responseIsUserNotFound401(error)) {
      _scheduleForceLogin();
    }
    handler.next(error);
  },
);
