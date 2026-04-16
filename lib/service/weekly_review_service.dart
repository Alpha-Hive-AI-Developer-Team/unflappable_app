import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class WeeklyReviewService {
  static Future<Response> getCurrentReview() {
    return DioHelper.getData(endPoint: EndPoints.weeklyReview.current);
  }

  static Future<Response> getReviewHistory({
    int? page,
    int? limit,
  }) {
    return DioHelper.getData(
      endPoint: EndPoints.weeklyReview.history,
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );
  }

  static Future<Response> createReview({
    required String biggestWin,
    required String biggestMiss,
    required String causeOfDrift,
    required String oneShiftForNextWeek,
  }) {
    return DioHelper.postData(
      endPoint: EndPoints.weeklyReview.current,
      data: {
        'biggestWin': biggestWin,
        'biggestMiss': biggestMiss,
        'causeOfDrift': causeOfDrift,
        'oneShiftForNextWeek': oneShiftForNextWeek,
      },
    );
  }
}
