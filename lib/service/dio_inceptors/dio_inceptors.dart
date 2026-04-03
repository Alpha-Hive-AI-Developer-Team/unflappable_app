
import 'package:dio/dio.dart';

import 'package:unflappable/service/dio_inceptors/auth_inceptor.dart';
import 'package:unflappable/service/dio_inceptors/logger_inceptor.dart';


final List<Interceptor> dioInterceptoprs = [
  authInterceptor,
  loggerInterceptor,
];
final List<Interceptor> dioInterceptoprsWithoutToken = [
  loggerInterceptor,
];