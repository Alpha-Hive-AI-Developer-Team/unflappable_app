import 'package:dio/dio.dart';
import 'package:unflappable/features/Subscription/models/subscription_models.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class SubscriptionService {
  static Map<String, dynamic>? _unwrapData(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    if (body['success'] != true) return null;
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  static void _ensureSuccess(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['success'] == true) {
      return;
    }
    final message = body is Map && body['message'] is String
        ? body['message'] as String
        : 'Subscription request failed.';
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: message,
      type: DioExceptionType.badResponse,
    );
  }

  static Future<SubscriptionPlansPayload> fetchPlans() async {
    final response = await DioHelper.getData(endPoint: EndPoints.subscription.plans);
    final data = _unwrapData(response.data);
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid subscription plans response.',
        type: DioExceptionType.badResponse,
      );
    }
    return SubscriptionPlansPayload.fromJson(data);
  }

  static Future<SubscriptionStatusPayload> fetchStatus() async {
    final response = await DioHelper.getData(endPoint: EndPoints.subscription.status);
    final data = _unwrapData(response.data);
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid subscription status response.',
        type: DioExceptionType.badResponse,
      );
    }
    return SubscriptionStatusPayload.fromJson(data);
  }

  static Future<void> verify({required String receiptData}) async {
    final response = await DioHelper.postData(
      endPoint: EndPoints.subscription.verify,
      data: {'receiptData': receiptData},
    );
    _ensureSuccess(response);
  }

  static Future<void> restore({required String receiptData}) async {
    final response = await DioHelper.postData(
      endPoint: EndPoints.subscription.restore,
      data: {'receiptData': receiptData},
    );
    _ensureSuccess(response);
  }
}
