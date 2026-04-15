import 'package:dio/dio.dart';
import 'package:unflappable/core/storage/local_storage.dart';


final Interceptor authInterceptor = QueuedInterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
    final String? accessToken = LocalStorage.getData(LocalStorage.accessToken);
    final token = accessToken?.trim();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  },
  // onError: (DioException e, ErrorInterceptorHandler handler) async {
  //   log('Begging onError interceptor...');
  //   final options = e.response?.requestOptions;

  //   if (e.response?.statusCode == 403) {
  //     await AuthRepository.localLogout();
  //     Snackbars.expiredSession();
  //     return handler.reject(
  //       DioException(requestOptions: options!, message: 'Expired Session'),
  //     );
  //   }

  //   return handler.next(e);
  // },
);
