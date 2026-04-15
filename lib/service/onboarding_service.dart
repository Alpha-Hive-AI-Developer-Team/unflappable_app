import 'package:dio/dio.dart';
import 'package:unflappable/features/Onboarding/Model/onboarding_model.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class OnboardingService {
  static Future<Response> complete({
    required Map<int, int> answers,
  }) async {
    final role = _answerText(0, answers);
    final challenge = _answerText(1, answers);
    final goal = _answerText(2, answers);
    final dailyReminders = answers[3] == 0;

    return DioHelper.postData(
      endPoint: EndPoints.onboarding.complete,
      data: {
        'role': role,
        'challenge': challenge,
        'goal': goal,
        'dailyReminders': dailyReminders,
      },
    );
  }

  static String _answerText(int questionIndex, Map<int, int> answers) {
    final optionIndex = answers[questionIndex];
    if (optionIndex == null) return '';
    final options = questions[questionIndex].options;
    if (optionIndex < 0 || optionIndex >= options.length) return '';
    return options[optionIndex];
  }
}
