import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_inceptors/dio_inceptors.dart';

abstract final class DioHelper {
  static late Dio _dio;
  static late Dio _dioWithoutToken;
  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _sendTimeout = Duration(seconds: 20);
  static const Duration _receiveTimeout = Duration(seconds: 20);

  static void init() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: _connectTimeout,
        sendTimeout: _sendTimeout,
        receiveTimeout: _receiveTimeout,
        receiveDataWhenStatusError: true,
        contentType: 'application/json',
        headers: {},
      ),
    )..interceptors.addAll(dioInterceptors);

    _dioWithoutToken = Dio(
      BaseOptions(
        connectTimeout: _connectTimeout,
        sendTimeout: _sendTimeout,
        receiveTimeout: _receiveTimeout,
        receiveDataWhenStatusError: true,
        contentType: 'application/json',
        headers: {},
      ),
    )..interceptors.addAll(dioInterceptorsWithoutToken);
  }

  static Future<Response> getData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(endPoint, queryParameters: queryParameters);
  }

  static Future<Response> getDataWithoutAuth({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dioWithoutToken.get(endPoint, queryParameters: queryParameters);
  }

  static Future<Response> postData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dio.post(endPoint, queryParameters: queryParameters, data: data);
  }

  static Future<Response> postWithOutAuthData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dioWithoutToken.post(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }

  static Future<Response> putData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dio.put(endPoint, queryParameters: queryParameters, data: data);
  }

  static Future<Response> patchData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dio.patch(endPoint, queryParameters: queryParameters, data: data);
  }

  static Future<Response> deleteData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    return _dio.delete(endPoint, queryParameters: queryParameters, data: data);
  }

  static Future<Response> postAuthData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    required dynamic data,
  }) async {
    return _dioWithoutToken.post(
      endPoint,
      queryParameters: queryParameters,
      data: data,
    );
  }
}
