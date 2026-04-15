import 'package:dio/dio.dart';

import 'package:unflappable/service/dio_inceptors/auth_inceptor.dart';
import 'package:unflappable/service/dio_inceptors/logger_inceptor.dart';

final List<Interceptor> dioInterceptors = [authInterceptor, loggerInterceptor];
final List<Interceptor> dioInterceptorsWithoutToken = [loggerInterceptor];
