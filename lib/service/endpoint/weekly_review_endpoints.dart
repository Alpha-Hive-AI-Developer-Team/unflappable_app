part of 'endpoint.dart';

class _WeeklyReview {
  final String _apiBaseUrl;

  factory _WeeklyReview({required String apiBaseUrl}) {
    _instance ??= _WeeklyReview._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _WeeklyReview._sharedInstance({required String apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl;

  static _WeeklyReview? _instance;

  String get _weeklyReviewController => '$_apiBaseUrl/api/weekly-review';

  String get current => _weeklyReviewController;
  String get history => '$_weeklyReviewController/history';
}
