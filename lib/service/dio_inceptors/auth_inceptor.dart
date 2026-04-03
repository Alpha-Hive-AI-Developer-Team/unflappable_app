import 'package:dio/dio.dart';
import 'package:unflappable/core/storage/local_storage.dart';


final Interceptor authInterceptor = QueuedInterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
    String? accessToken = LocalStorage.getData(LocalStorage.accessToken);

    options.headers.addAll({
      'Authorization': 'Bearer ${accessToken ?? ''}',
      'Accept': 'application/json',
    });
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
