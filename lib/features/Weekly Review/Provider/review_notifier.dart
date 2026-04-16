import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Weekly%20Review/Model/review_model.dart';
import 'package:unflappable/features/Weekly%20Review/Provider/review_state.dart';
import 'package:unflappable/service/weekly_review_service.dart';
import 'package:dio/dio.dart';

class WeeklyReviewNotifier extends StateNotifier<WeeklyReviewState> {
  WeeklyReviewNotifier() : super(const WeeklyReviewState());

  Future<void> loadInitial({bool force = false}) async {
    if (state.isLoading) return;
    if (state.hasLoaded && !force) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentResponse = await WeeklyReviewService.getCurrentReview();
      final historyResponse = await WeeklyReviewService.getReviewHistory(
        page: 1,
        limit: 10,
      );

      final currentPayload = _extractPayload(currentResponse.data);
      final historyItems = _extractList(historyResponse.data);
      final currentReview = _extractReview(currentPayload);
      final history = historyItems.map(WeeklyReviewData.fromJson).toList();

      state = state.copyWith(
        saved: currentReview,
        history: history,
        isLoading: false,
        hasLoaded: true,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final historyResponse = await WeeklyReviewService.getReviewHistory(
          page: 1,
          limit: 10,
        );
        final historyItems = _extractList(historyResponse.data);
        state = state.copyWith(
          saved: null,
          history: historyItems.map(WeeklyReviewData.fromJson).toList(),
          isLoading: false,
          hasLoaded: true,
          clearSaved: true,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Unable to load weekly review.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load weekly review.',
      );
    }
  }

  void openAddScreen() => state = state.copyWith(
    showAddScreen: true,
    draft: state.saved ?? const WeeklyReviewData(),
  );

  void closeAddScreen() => state = state.copyWith(showAddScreen: false);

  void setBiggestWin(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(biggestWin: v));

  void setBiggestMiss(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(biggestMiss: v));

  void setCauseOfDrift(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(causeOfDrift: v));

  void setOneShift(String v) =>
      state = state.copyWith(draft: state.draft.copyWith(oneShiftNextWeek: v));

  Future<void> saveReview() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await WeeklyReviewService.createReview(
        biggestWin: state.draft.biggestWin,
        biggestMiss: state.draft.biggestMiss,
        causeOfDrift: state.draft.causeOfDrift,
        oneShiftForNextWeek: state.draft.oneShiftNextWeek,
      );
      await loadInitial(force: true);
      state = state.copyWith(
        isLoading: false,
        showAddScreen: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _dioErrorMessage(e, fallback: 'Unable to save review.'),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to save review.',
      );
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
        final items = payload['items'] ?? payload['history'] ?? payload['reviews'];
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

  WeeklyReviewData? _extractReview(Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    final candidates = [
      data['review'],
      data['weeklyReview'],
      data['currentReview'],
      data,
    ];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        final review = WeeklyReviewData.fromJson(candidate);
        if (review.hasAnyEntry) return review;
      } else if (candidate is Map) {
        final review = WeeklyReviewData.fromJson(Map<String, dynamic>.from(candidate));
        if (review.hasAnyEntry) return review;
      }
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

final weeklyReviewProvider =
    StateNotifierProvider<WeeklyReviewNotifier, WeeklyReviewState>(
      (_) => WeeklyReviewNotifier(),
    );
