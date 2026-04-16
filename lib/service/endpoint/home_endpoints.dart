part of 'endpoint.dart';

class _Home {
  final String _apiBaseUrl;

  factory _Home({required String apiBaseUrl}) {
    _instance ??= _Home._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Home._sharedInstance({required String apiBaseUrl}) : _apiBaseUrl = apiBaseUrl;

  static _Home? _instance;

  String get _homeController => '$_apiBaseUrl/api/home';
  String get _missionsController => '$_apiBaseUrl/api/missions';

  String get dashboard => _homeController;
  String get missions => _missionsController;
  String get todayMission => '$_missionsController/today';
  String missionById(String missionId) => '$_missionsController/$missionId';
  String completeTask(String missionId, String taskId) =>
      '$_missionsController/$missionId/tasks/$taskId/complete';
  String uncompleteTask(String missionId, String taskId) =>
      '$_missionsController/$missionId/tasks/$taskId/uncomplete';
  String get missionHistory => '$_missionsController/history';
}
