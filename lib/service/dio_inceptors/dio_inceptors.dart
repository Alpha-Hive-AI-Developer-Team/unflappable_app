import 'package:dio/dio.dart';

import 'package:unflappable/service/dio_inceptors/auth_inceptor.dart';
import 'package:unflappable/service/dio_inceptors/logger_inceptor.dart';
import 'package:unflappable/service/dio_inceptors/user_not_found_interceptor.dart';

/// [userNotFound401Interceptor] last so on error it runs first (Dio LIFO).
final List<Interceptor> dioInterceptors = [
  authInterceptor,
  loggerInterceptor,
  userNotFound401Interceptor,
];
final List<Interceptor> dioInterceptorsWithoutToken = [loggerInterceptor];
