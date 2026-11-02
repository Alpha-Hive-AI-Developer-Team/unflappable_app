import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/navigation/root_navigator_key.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/core/utils/session_provider_reset.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';

bool _handlingUnauthorized401 = false;

bool _responseIsUnauthorized401(DioException e) =>
    e.response?.statusCode == 401;

/// Clears the stored session and sends the user to Login when an authenticated
/// API request reports an invalid or expired JWT.
void _scheduleForceLogin() {
  if (_handlingUnauthorized401) return;
  _handlingUnauthorized401 = true;

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
        _handlingUnauthorized401 = false;
      });
    }
  });
}

final Interceptor userNotFound401Interceptor = InterceptorsWrapper(
  onError: (DioException error, ErrorInterceptorHandler handler) {
    if (_responseIsUnauthorized401(error)) {
      _scheduleForceLogin();
    }
    handler.next(error);
  },
);
