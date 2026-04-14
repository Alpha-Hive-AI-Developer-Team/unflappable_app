import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class OnboardingService {
  static Future<Response> complete({
    required Map<int, int> answers,
  }) async {
    return DioHelper.postData(
      endPoint: EndPoints.onboarding.complete,
      data: {
        'answers': answers.map((questionIndex, answerIndex) =>
            MapEntry(questionIndex.toString(), answerIndex)),
      },
    );
  }
}
