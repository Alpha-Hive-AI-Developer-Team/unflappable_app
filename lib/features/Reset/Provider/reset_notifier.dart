import 'package:dio/dio.dart';
import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Reset/Models/reset_history_item.dart';
import 'package:unflappable/features/Reset/Provider/reset_state.dart';
import 'package:unflappable/service/reset_service.dart';

class ResetNotifier extends StateNotifier<ResetState> {
  ResetNotifier() : super(const ResetState()) {
    loadInitial();
  }

  // ── Trigger ──────────────────────────────────────────────────────────────

  void setTrigger(String value) {
    state = state.copyWith(trigger: value);
  }

  // ── Emotions ─────────────────────────────────────────────────────────────

  void toggleEmotion(String emotion) {
    final current = List<String>.from(state.selectedEmotions);
    if (current.contains(emotion)) {
      current.remove(emotion);
    } else {
      current.add(emotion);
    }
    state = state.copyWith(selectedEmotions: current);
  }

  Future<void> loadInitial() async {
    if (state.status == ResetStatus.loading) return;

    state = state.copyWith(status: ResetStatus.loading, errorMessage: null);

    try {
      final landingResponse = await ResetService.getLanding();
      final historyResponse = await ResetService.getHistory(page: 1, limit: 20);

      final landingPayload = _extractPayload(landingResponse.data);
      final historyItems = _extractList(
        historyResponse.data,
      ).map(ResetHistoryItem.fromJson).toList();

      state = state.copyWith(
        status: ResetStatus.initial,
        emotions: _extractEmotions(landingPayload) ?? state.emotions,
        resetsUsedToday:
            _extractInt(landingPayload, [
              'resetsUsedToday',
              'resets_used_today',
              'usedToday',
            ]) ??
            state.resetsUsedToday,
        dailyResetLimit:
            _extractInt(landingPayload, [
              'dailyResetLimit',
              'daily_reset_limit',
              'limit',
            ]) ??
            state.dailyResetLimit,
        totalReset:
            _extractInt(landingPayload, [
              'totalReset',
              'total_reset',
              'total',
            ]) ??
            historyItems.length,
        resetHistory: historyItems,
        errorMessage: null,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Unable to load reset history.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: 'Unable to load reset history.',
      );
    }
  }

  Future<void> runReset() async {
    if (!state.hasResetsLeft) return;

    state = state.copyWith(status: ResetStatus.loading, errorMessage: null);

    try {
      final feeling = state.selectedEmotions.join(', ');
      final response = await ResetService.triggerReset(
        feeling: feeling,
        trigger: state.trigger ?? '',
      );
      final payload = _extractPayload(response.data);
      final historyItems = _extractList(
        response.data,
      ).map(ResetHistoryItem.fromJson).toList();

      state = state.copyWith(
        status: ResetStatus.success,
        reframeText:
            _extractString(payload, [
              'reframeText',
              'reframe',
              'reframe_text',
            ]) ??
            state.reframeText,
        nextActionText:
            _extractString(payload, [
              'nextActionText',
              'nextAction',
              'next_action',
            ]) ??
            state.nextActionText,
        resetsUsedToday: state.resetsUsedToday + 1,
        totalReset: state.totalReset + 1,
        resetHistory: historyItems.isNotEmpty
            ? historyItems
            : [
                ResetHistoryItem(
                  trigger: state.trigger ?? 'Unknown',
                  emotions: List<String>.from(state.selectedEmotions),
                  reframeText:
                      _extractString(payload, [
                        'reframeText',
                        'reframe',
                        'reframe_text',
                      ]) ??
                      '',
                  nextActionText:
                      _extractString(payload, [
                        'nextActionText',
                        'nextAction',
                        'next_action',
                      ]) ??
                      '',
                  timestamp: DateTime.now(),
                ),
                ...state.resetHistory,
              ],
      );

      await _refreshHistory();
    } on DioException catch (e) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: _dioErrorMessage(e, fallback: 'Unable to run reset.'),
      );
    } catch (_) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: 'Unable to run reset.',
      );
    }
  }

  Future<void> _refreshHistory() async {
    try {
      final historyResponse = await ResetService.getHistory(page: 1, limit: 20);
      final historyItems = _extractList(
        historyResponse.data,
      ).map(ResetHistoryItem.fromJson).toList();

      state = state.copyWith(
        resetHistory: historyItems,
        totalReset: historyItems.length,
      );
    } catch (_) {
      // Keep existing history if refresh fails.
    }
  }

  // ── Reset flow back to initial ────────────────────────────────────────────

  void resetFlow() {
    state = ResetState(
      resetsUsedToday: state.resetsUsedToday,
      totalReset: state.totalReset,
      dailyResetLimit: state.dailyResetLimit,
      emotions: state.emotions,
      resetHistory: state.resetHistory,
    );
  }

  void clearError() {
    state = state.copyWith(status: ResetStatus.initial, errorMessage: null);
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

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      if (payload is Map<String, dynamic>) {
        final items =
            payload['items'] ?? payload['history'] ?? payload['resets'];
        if (items is List) {
          return items
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }
    return const [];
  }

  String? _extractString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  int? _extractInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  List<String>? _extractEmotions(Map<String, dynamic> data) {
    final emotionsValue = data['emotions'] ?? data['feelings'];
    if (emotionsValue == null) return null;
    if (emotionsValue is List) {
      return emotionsValue.whereType<String>().toList();
    }
    if (emotionsValue is String) {
      return emotionsValue
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return null;
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
