import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Home/model/mission.dart';
import 'package:unflappable/features/Mission%20History/missionHistory_state.dart';
import 'package:unflappable/service/home_service.dart';

// ---------------------------------------------------------------------------
// NOTIFIER
// ---------------------------------------------------------------------------

class MissionHistoryNotifier extends StateNotifier<MissionHistoryState> {
  MissionHistoryNotifier() : super(const MissionHistoryState()) {
    loadMissions();
  }

  /// Fetch mission history from the API.
  Future<void> loadMissions() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await HomeService.getMissionHistory();
      final missions = _extractMissions(response.data);
      state = state.copyWith(missions: missions, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Failed to load mission history. Please try again.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load mission history. Please try again.',
      );
    }
  }

  /// Pull-to-refresh or manual retry
  Future<void> refresh() => loadMissions();

  List<Mission> _extractMissions(dynamic data) {
    return _extractList(data)
        .map((item) => Mission.fromJson(item))
        .where((mission) => mission.id.isNotEmpty || mission.objective.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (payload is Map<String, dynamic>) {
        final items = payload['items'] ?? payload['history'] ?? payload['missions'];
        if (items is List) {
          return items
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      final items = data['items'] ?? data['history'] ?? data['missions'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
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

// ---------------------------------------------------------------------------
// PROVIDER
// ---------------------------------------------------------------------------

final missionHistoryProvider =
    StateNotifierProvider<MissionHistoryNotifier, MissionHistoryState>(
      (ref) => MissionHistoryNotifier(),
    );
