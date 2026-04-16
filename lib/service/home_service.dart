import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class HomeService {
  static Future<Response> getHome() {
    return DioHelper.getData(endPoint: EndPoints.home.dashboard);
  }

  static Future<Response> createMission({
    required String objective,
    required List<String> tasks,
  }) {
    return DioHelper.postData(
      endPoint: EndPoints.home.missions,
      data: {
        'objective': objective,
        'tasks': tasks.map((title) => {'title': title}).toList(),
      },
    );
  }

  static Future<Response> getTodayMission() {
    return DioHelper.getData(endPoint: EndPoints.home.todayMission);
  }

  static Future<Response> getMissionById(String missionId) {
    return DioHelper.getData(endPoint: EndPoints.home.missionById(missionId));
  }

  static Future<Response> completeTask({
    required String missionId,
    required String taskId,
  }) {
    return DioHelper.patchData(
      endPoint: EndPoints.home.completeTask(missionId, taskId),
      data: const <String, dynamic>{},
    );
  }

  static Future<Response> uncompleteTask({
    required String missionId,
    required String taskId,
  }) {
    return DioHelper.patchData(
      endPoint: EndPoints.home.uncompleteTask(missionId, taskId),
      data: const <String, dynamic>{},
    );
  }

  static Future<Response> getMissionHistory({
    int? page,
    int? limit,
    String? startDate,
    String? endDate,
  }) {
    return DioHelper.getData(
      endPoint: EndPoints.home.missionHistory,
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
        if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
      },
    );
  }

  static Future<Response> deleteMission(String missionId) {
    return DioHelper.deleteData(endPoint: EndPoints.home.missionById(missionId));
  }
}
