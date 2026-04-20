import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_state.dart';
import 'package:unflappable/features/Home/model/mission.dart';
import 'package:unflappable/features/Home/model/mission_task.dart';
import 'package:unflappable/service/home_service.dart';
import 'package:unflappable/service/progress_service.dart';
import 'package:unflappable/service/reset_service.dart';
import 'package:dio/dio.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  Future<void> loadHome({bool force = false}) async {
    if (state.isLoading) return;
    if (state.hasLoaded && !force) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final homeResponse = await HomeService.getHome();
      final progressResponse = await ProgressService.getProgress();
      final resetHistoryResponse = await ResetService.getHistory(page: 1, limit: 20);
      _extractPayload(homeResponse.data);
      final progressPayload = _extractPayload(progressResponse.data);
      final todayMissionResult = await _fetchTodayMissionResult();
      final resetHistoryCount = _countResetHistoryItems(resetHistoryResponse.data);
      final streakPayload = _readMap(progressPayload, 'streak');
      final missionsPayload = _readMap(progressPayload, 'missions');
      final performancePayload = _readMap(progressPayload, 'performanceStats');
      final taskCompletionPayload = _readMap(
        performancePayload,
        'taskCompletion',
      );
      final totalResetsPayload = _readMap(performancePayload, 'totalResets');

      state = state.copyWith(
        dayStreak: _readInt(streakPayload, const ['currentStreak']),
        longestStreak: _readInt(streakPayload, const ['longestStreak']),
        missionCount: _readInt(missionsPayload, const ['totalCompleted']),
        totalTasks: _readTaskTotal(taskCompletionPayload),
        completedTasks: _readCompletedTasks(taskCompletionPayload),
        totalResets: resetHistoryCount,
        taskCompletionLabel: _readString(taskCompletionPayload, const [
          'label',
        ], fallback: state.taskCompletionLabel),
        taskCompletionSubtitle: _readString(taskCompletionPayload, const [
          'subtitle',
        ], fallback: state.taskCompletionSubtitle),
        taskCompletionPercentage: _readPercentage(taskCompletionPayload, const [
          'percentage',
        ]),
        totalResetsLabel: _readString(totalResetsPayload, const [
          'label',
        ], fallback: state.totalResetsLabel),
        totalResetsSubtitle: _readString(totalResetsPayload, const [
          'subtitle',
        ], fallback: state.totalResetsSubtitle),
        totalResetsPercentage: _readPercentage(totalResetsPayload, const [
          'percentage',
        ]),
        activeMission: todayMissionResult.found
            ? todayMissionResult.mission
            : null,
        isLoading: false,
        hasLoaded: true,
        isRefreshingCompletedMission: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshingCompletedMission: false,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Unable to load the home screen.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isRefreshingCompletedMission: false,
        errorMessage: 'Unable to load the home screen.',
      );
    }
  }

  Future<void> createMission({
    required String objective,
    required List<String> tasks,
  }) async {
    if (state.isCreatingMission) return;

    state = state.copyWith(isCreatingMission: true, clearError: true);

    try {
      await HomeService.createMission(objective: objective, tasks: tasks);
      await loadHome(force: true);
      state = state.copyWith(
        isCreatingMission: false,
        successMessage: 'Mission started successfully',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isCreatingMission: false,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Unable to create mission.',
        ),
      );
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isCreatingMission: false,
        errorMessage: 'Unable to create mission.',
      );
      rethrow;
    }
  }

  Future<void> toggleTask(String taskId) async {
    final mission = state.activeMission;
    if (mission == null) return;

    MissionTask? task;
    for (final currentTask in mission.tasks) {
      if (currentTask.id == taskId) {
        task = currentTask;
        break;
      }
    }
    if (task == null) return;

    final isFinalTaskCompletion =
        mission.tasks.isNotEmpty &&
        mission.tasks.last.id == taskId &&
        mission.tasks
            .take(mission.tasks.length - 1)
            .every((previousTask) => previousTask.isCompleted);

    state = state.copyWith(clearError: true, activeTaskId: taskId);

    try {
      await HomeService.completeTask(missionId: mission.id, taskId: taskId);
      await loadHome(force: true);

      if (isFinalTaskCompletion) {
        state = state.copyWith(
          clearActiveTask: true,
          successMessage: "Today's mission completed successfully",
        );
        return;
      }

      final refreshedMission = await _fetchMissionById(mission.id);
      state = state.copyWith(
        activeMission: refreshedMission ?? state.activeMission,
        clearActiveTask: true,
        successMessage: '${task.title} completed',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        clearActiveTask: true,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Unable to update the task right now.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        clearActiveTask: true,
        errorMessage: 'Unable to update the task right now.',
      );
    }
  }

  Future<void> refreshCompletedMission() async {
    state = state.copyWith(
      isRefreshingCompletedMission: true,
      clearError: true,
      clearMission: true,
    );

    try {
      await loadHome(force: true);
    } finally {
      state = state.copyWith(
        clearMission: true,
        isRefreshingCompletedMission: false,
      );
    }
  }

  void markMissionDone() {
    final mission = state.activeMission;
    if (mission == null) return;
    state = state.copyWith(clearMission: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccessMessage() {
    state = state.copyWith(clearSuccess: true);
  }

  Future<_TodayMissionResult> _fetchTodayMissionResult() async {
    try {
      final response = await HomeService.getTodayMission();
      final payload = _extractPayload(response.data);
      return _TodayMissionResult(
        found: true,
        mission: _extractMission(payload),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const _TodayMissionResult(found: false);
      }
      rethrow;
    }
  }

  Future<Mission?> _fetchMissionById(String missionId) async {
    try {
      final response = await HomeService.getMissionById(missionId);
      final payload = _extractPayload(response.data);
      return _extractMission(payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Map<String, dynamic> _extractPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  int _countResetHistoryItems(dynamic data) {
    if (data is List) return data.length;

    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is List) return payload.length;

      if (payload is Map<String, dynamic>) {
        for (final key in const ['items', 'history', 'historyPreview', 'resets']) {
          final items = payload[key];
          if (items is List) return items.length;
        }
      }

      for (final key in const ['items', 'history', 'historyPreview', 'resets']) {
        final items = data[key];
        if (items is List) return items.length;
      }
    }

    return 0;
  }

  Mission? _extractMission(Map<String, dynamic> source) {
    final candidates = [
      source['activeMission'],
      source['todayMission'],
      source['mission'],
      source['today'],
      source,
    ];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        final mission = Mission.fromJson(candidate);
        if (mission.id.isNotEmpty || mission.objective.isNotEmpty) {
          return mission;
        }
      } else if (candidate is Map) {
        final mission = Mission.fromJson(Map<String, dynamic>.from(candidate));
        if (mission.id.isNotEmpty || mission.objective.isNotEmpty) {
          return mission;
        }
      }
    }

    return null;
  }

  int _readInt(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  Map<String, dynamic> _readMap(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  String _readString(
    Map<String, dynamic> source,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  double _readPercentage(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) return value.toDouble() / 100;
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed / 100;
      }
    }
    return 0;
  }

  int _readCompletedTasks(Map<String, dynamic> source) {
    final subtitle = _readString(source, const ['subtitle'], fallback: '');
    final match = RegExp(r'(\d+)\s+of\s+(\d+)').firstMatch(subtitle);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return 0;
  }

  int _readTaskTotal(Map<String, dynamic> source) {
    final subtitle = _readString(source, const ['subtitle'], fallback: '');
    final match = RegExp(r'(\d+)\s+of\s+(\d+)').firstMatch(subtitle);
    if (match != null) {
      return int.tryParse(match.group(2) ?? '') ?? 0;
    }
    return 0;
  }

  String _dioErrorMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (_) => HomeNotifier(),
);

class _TodayMissionResult {
  final bool found;
  final Mission? mission;

  const _TodayMissionResult({required this.found, this.mission});
}
