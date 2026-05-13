import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Reset/Models/reset_history_item.dart';
import 'package:unflappable/features/Reset/Provider/reset_state.dart';
import 'package:unflappable/service/reset_service.dart';

class ResetNotifier extends StateNotifier<ResetState> {
  final Ref _ref;

  bool get _isPro => _ref.read(userProvider).isPro;

  ResetNotifier({required Ref ref}) : _ref = ref, super(const ResetState()) {
    loadInitial();
  }

  static const _resetsUsedTodayKeys = [
    'resetsUsedToday',
    'resets_used_today',
    'resetUsedToday',
    'reset_used_today',
    'usedToday',
    'used_today',
    'usedResetToday',
    'used_reset_today',
    'todayUsedReset',
    'today_used_reset',
    'usedResetCount',
    'used_reset_count',
    'todayUsedResetCount',
    'today_used_reset_count',
    'resetsToday',
    'resets_today',
    'todayResets',
    'today_resets',
    'resetCountToday',
    'reset_count_today',
  ];

  static const _dailyLimitKeys = [
    'dailyLimit',
    'daily_limit',
    'dailyResetLimit',
    'daily_reset_limit',
    'limit',
  ];

  static const _totalResetKeys = [
    'totalReset',
    'total_reset',
    'totalResets',
    'total_resets',
    'total',
    'totalResets',
    'total_resets',
    'resets_total',
  ];

  // ── Trigger ───────────────────────────────────────────────────────────────

  void setTrigger(String value) {
    state = state.copyWith(trigger: value);
  }

  // ── Emotions ──────────────────────────────────────────────────────────────

  void toggleEmotion(String emotion) {
    final current = List<String>.from(state.selectedEmotions);
    if (current.contains(emotion)) {
      current.remove(emotion);
    } else {
      current.add(emotion);
    }
    state = state.copyWith(selectedEmotions: current);
  }

  // ── Load Initial ──────────────────────────────────────────────────────────
  // FIX: This is now the single source of truth for resetsUsedToday,
  // dailyResetLimit, totalReset, and resetHistory. It always overwrites
  // state with values from the API, so re-opening the app always reflects
  // the backend's reality rather than an in-memory counter that resets to 0.

  Future<void> loadInitial({bool silent = false}) async {
    if (state.status == ResetStatus.loading) return;

    if (!silent) {
      state = state.copyWith(status: ResetStatus.loading, errorMessage: null);
    } else {
      state = state.copyWith(errorMessage: null);
    }

    try {
      final landingResponse = await ResetService.getLanding();
      final landingData = landingResponse.data;
      final landingPayload = _extractPrimaryPayload(landingData);
      final isProLanding = _readOptionalIsProFromResponse(landingData);
      if (isProLanding == true) {
        _ref.read(userProvider.notifier).syncIsProFromAuxiliaryApi(true);
      }

      final historyData = await _fetchHistoryDataSafely();
      final isProHistory = _readOptionalIsProFromResponse(historyData);
      if (isProHistory == true) {
        _ref.read(userProvider.notifier).syncIsProFromAuxiliaryApi(true);
      }

      final historyItems = _extractHistoryItems(
        historyData,
        landingData,
      );

      // FIX: Always pull counts from the API response. Never fall back to the
      // in-memory state value — that's what caused the "shows 1, then 0 on
      // restart" bug. If the API doesn't return a field, default to 0 / 1.
      final int resetsUsedToday =
          _extractInt(landingPayload, _resetsUsedTodayKeys) ??
          _extractInt(landingData, _resetsUsedTodayKeys) ??
          _extractInt(historyData, _resetsUsedTodayKeys) ??
          0;
      final int dailyLimit =
          _extractInt(landingPayload, _dailyLimitKeys) ??
          _extractInt(landingData, _dailyLimitKeys) ??
          1;
      final int totalResets =
          _extractInt(landingPayload, _totalResetKeys) ??
          _extractInt(landingData, _totalResetKeys) ??
          _extractInt(historyData, _totalResetKeys) ??
          historyItems.length;

      final unlimitedDailyResets =
          isProLanding == true || isProHistory == true;

      state = state.copyWith(
        status: ResetStatus.initial,
        resetsUsedToday: resetsUsedToday,
        dailyResetLimit: dailyLimit,
        totalReset: totalResets,
        resetHistory: historyItems,
        errorMessage: null,
        unlimitedDailyResets: unlimitedDailyResets,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Unable to load reset history.',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: 'Unable to load reset history. $e',
      );
    }
  }

  // ── Run Reset ─────────────────────────────────────────────────────────────
  // FIX: Guard is now purely API-driven. After a successful reset the state is
  // updated from the server response (or by incrementing if the server doesn't
  // return updated counts), then _refreshLanding() is called to sync the
  // authoritative count back from the backend.

  Future<void> runReset() async {
    // FIX: Check limit before proceeding. Set showLimitError so the UI can
    // display the snackbar, but do NOT navigate forward.
    if (!state.hasResetsLeft) {
      state = state.copyWith(showLimitError: true);
      return;
    }

    state = state.copyWith(status: ResetStatus.loading, errorMessage: null);

    try {
      final feeling = state.selectedEmotions.join(', ');
      final response = await ResetService.triggerReset(
        feeling: feeling,
        trigger: state.trigger ?? '',
      );

      final responseData = response.data;
      final payload = _extractPrimaryPayload(responseData);

      final String? reframeText = _extractString(payload, [
        'reframeText',
        'reframe',
        'reframe_text',
      ]);
      final String? nextActionText = _extractString(payload, [
        'nextActionText',
        'nextAction',
        'next_action',
      ]);

      // FIX: Prefer server-returned counts. Fall back to incrementing the
      // current state value (not zero) so the UI stays consistent even when
      // the reset endpoint doesn't echo back usage counts.
      final int? serverResetsUsedToday = _extractInt(
        payload,
        _resetsUsedTodayKeys,
      ) ??
          _extractInt(responseData, _resetsUsedTodayKeys);
      final int? serverTotalReset = _extractInt(payload, _totalResetKeys);

      state = state.copyWith(
        status: ResetStatus.success,
        reframeText: reframeText ?? state.reframeText,
        nextActionText: nextActionText ?? state.nextActionText,
        resetsUsedToday: serverResetsUsedToday ?? state.resetsUsedToday + 1,
        totalReset: serverTotalReset ?? state.totalReset + 1,
      );

      // FIX: After a successful reset, re-fetch the landing data so that
      // resetsUsedToday is authoritative from the server on the next render.
      // This also refreshes the history list.
      await _refreshLanding();
    } on DioException catch (e) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: _dioErrorMessage(e, fallback: 'Unable to run reset.'),
      );
    } catch (e) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: 'Unable to run reset. $e',
      );
    }
  }

  // ── Refresh Landing ───────────────────────────────────────────────────────
  // FIX: Replaces the old _refreshHistory(). Re-fetches both the landing
  // endpoint (for accurate resetsUsedToday / dailyLimit counts) and the
  // history endpoint. This ensures that after a reset completes, and every
  // time the screen is revisited, the count the user sees matches the backend.

  Future<void> _refreshLanding() async {
    try {
      final landingResponse = await ResetService.getLanding();
      final landingData = landingResponse.data;
      final landingPayload = _extractPrimaryPayload(landingData);
      final isProLanding = _readOptionalIsProFromResponse(landingData);
      if (isProLanding == true) {
        _ref.read(userProvider.notifier).syncIsProFromAuxiliaryApi(true);
      }

      final historyData = await _fetchHistoryDataSafely();
      final isProHistory = _readOptionalIsProFromResponse(historyData);
      if (isProHistory == true) {
        _ref.read(userProvider.notifier).syncIsProFromAuxiliaryApi(true);
      }

      final historyItems = _extractHistoryItems(
        historyData,
        landingData,
      );

      final int resetsUsedToday =
          _extractInt(landingPayload, _resetsUsedTodayKeys) ??
          _extractInt(landingData, _resetsUsedTodayKeys) ??
          _extractInt(historyData, _resetsUsedTodayKeys) ??
          state.resetsUsedToday;
      final int dailyLimit =
          _extractInt(landingPayload, _dailyLimitKeys) ??
          _extractInt(landingData, _dailyLimitKeys) ??
          state.dailyResetLimit;
      final int totalResets =
          _extractInt(landingPayload, _totalResetKeys) ??
          _extractInt(landingData, _totalResetKeys) ??
          _extractInt(historyData, _totalResetKeys) ??
          historyItems.length;

      final unlimitedDailyResets =
          isProLanding == true || isProHistory == true;

      // FIX: Preserve the current status (success) when refreshing — only
      // update the data fields so the success overlay stays visible.
      state = state.copyWith(
        resetsUsedToday: resetsUsedToday,
        dailyResetLimit: dailyLimit,
        totalReset: totalResets,
        resetHistory: historyItems,
        unlimitedDailyResets: unlimitedDailyResets,
      );
    } catch (_) {
      // If the refresh fails, keep whatever state we already have. The
      // optimistic increment in runReset() is already applied.
    }
  }

  // ── Reset Flow ────────────────────────────────────────────────────────────
  // Clears per-session fields (trigger, emotions, result) while preserving
  // the API-sourced counters and history.

  void resetFlow() {
    state = ResetState(
      resetsUsedToday: state.resetsUsedToday,
      totalReset: state.totalReset,
      dailyResetLimit: state.dailyResetLimit,
      emotions: state.emotions,
      resetHistory: state.resetHistory,
      unlimitedDailyResets: state.unlimitedDailyResets,
    );
  }

  void clearLimitError() {
    state = state.copyWith(showLimitError: false);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int? _extractInt(dynamic data, List<String> keys) {
    if (data is Map) {
      final raw = Map<String, dynamic>.from(data);
      final normalizedKeys = keys.map(_normalizeKey).toSet();
      for (final entry in raw.entries) {
        if (!normalizedKeys.contains(_normalizeKey(entry.key))) continue;
        final value = entry.value;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      for (final nestedValue in raw.values) {
        final nestedInt = _extractInt(nestedValue, keys);
        if (nestedInt != null) return nestedInt;
      }
    } else if (data is List) {
      for (final item in data) {
        final nestedInt = _extractInt(item, keys);
        if (nestedInt != null) return nestedInt;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map) {
      final outer = Map<String, dynamic>.from(data);
      final payload = outer['data'];
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      if (payload is Map) {
        final inner = Map<String, dynamic>.from(payload);
        final items =
            inner['items'] ??
            inner['history'] ??
            inner['historyPreview'] ??
            inner['history_preview'] ??
            inner['recentHistory'] ??
            inner['recent_history'] ??
            inner['recentResets'] ??
            inner['recent_resets'] ??
            inner['resets'];
        if (items is List) {
          return items
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
      final items =
          outer['items'] ??
          outer['history'] ??
          outer['historyPreview'] ??
          outer['history_preview'] ??
          outer['recentHistory'] ??
          outer['recent_history'] ??
          outer['recentResets'] ??
          outer['recent_resets'] ??
          outer['resets'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }

  String? _extractString(Map<String, dynamic> data, List<String> keys) {
    final normalizedKeys = keys.map(_normalizeKey).toSet();
    for (final entry in data.entries) {
      if (!normalizedKeys.contains(_normalizeKey(entry.key))) continue;
      final value = entry.value;
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  Map<String, dynamic> _extractPrimaryPayload(dynamic data) {
    if (data is! Map) return <String, dynamic>{};
    final outer = Map<String, dynamic>.from(data.cast<String, dynamic>());
    final nestedData = outer['data'];
    if (nestedData is Map) {
      final payload = Map<String, dynamic>.from(nestedData.cast<String, dynamic>());
      for (final key in const ['summary', 'stats', 'usage', 'counts']) {
        final nested = payload[key];
        if (nested is Map) {
          return {
            ...payload,
            ...Map<String, dynamic>.from(nested.cast<String, dynamic>()),
          };
        }
      }
      return payload;
    }
    return outer;
  }

  Future<dynamic> _fetchHistoryDataSafely() async {
    try {
      final historyResponse = _isPro
          ? await ResetService.getHistory(page: 1, limit: 20)
          : await ResetService.getHistory();
      return historyResponse.data;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  List<ResetHistoryItem> _extractHistoryItems(
    dynamic primarySource,
    dynamic fallbackSource,
  ) {
    final primaryList = _extractList(primarySource);
    if (primaryList.isNotEmpty) {
      return primaryList.map(ResetHistoryItem.fromJson).toList();
    }
    final fallbackList = _extractList(fallbackSource);
    return fallbackList.map(ResetHistoryItem.fromJson).toList();
  }

  String _normalizeKey(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();

  bool? _readOptionalBoolKey(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) return null;
    final value = map[key];
    if (value is bool) return value;
    if (value is String) {
      final s = value.toLowerCase().trim();
      if (s == 'true') return true;
      if (s == 'false') return false;
    }
    return null;
  }

  bool? _readOptionalIsProFromResponse(dynamic data) {
    if (data is! Map) return null;
    final outer = Map<String, dynamic>.from(data.cast<String, dynamic>());
    final nested = outer['data'];
    final fromNested = nested is Map
        ? _readOptionalBoolKey(Map<String, dynamic>.from(nested), 'isPro')
        : null;
    final fromOuter = _readOptionalBoolKey(outer, 'isPro');
    return _mergeOptionalBoolOr(fromNested, fromOuter);
  }

  /// If either side is true, result is true. If both absent, null. If one
  /// absent and the other false, false.
  bool? _mergeOptionalBoolOr(bool? a, bool? b) {
    if (a == null && b == null) return null;
    return (a ?? false) || (b ?? false);
  }

  String _dioErrorMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return fallback;
  }
}
