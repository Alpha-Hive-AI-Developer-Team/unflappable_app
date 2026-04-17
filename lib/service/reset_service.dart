import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class ResetService {
  static Future<Response> getLanding() {
    return DioHelper.getData(endPoint: EndPoints.reset.landing);
  }

  static Future<Response> triggerReset({
    required String feeling,
    required String trigger,
  }) {
    return DioHelper.postData(
      endPoint: EndPoints.reset.trigger,
      data: {
        'feeling': feeling,
        'trigger': trigger,
      },
    );
  }

  static Future<Response> getHistory({int? page, int? limit}) {
    return DioHelper.getData(
      endPoint: EndPoints.reset.history,
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
  }
}
