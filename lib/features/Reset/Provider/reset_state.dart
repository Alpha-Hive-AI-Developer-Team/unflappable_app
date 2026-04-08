// lib/features/reset/models/reset_state.dart

import 'package:unflappable/features/Reset/Models/reset_history_item.dart';

enum ResetStatus { initial, loading, success, error }

class ResetState {
  final ResetStatus status;
  final String? trigger;
  final List<String> emotions;
  final List<String> selectedEmotions;
  final int resetsUsedToday;
  final int dailyResetLimit;
  final String? reframeText;
  final String? nextActionText;
  final String? errorMessage;
  final int totalReset;
  final List<ResetHistoryItem> resetHistory;

  const ResetState({
    this.status = ResetStatus.initial,
    this.trigger,
    this.emotions = const [
      'Frustrated',
      'Scattered',
      'Tense',
      'Angry',
      'Discouraged',
    ],
    this.selectedEmotions = const [],
    this.resetsUsedToday = 0,
    this.totalReset = 0,
    this.dailyResetLimit = 1,
    this.reframeText,
    this.nextActionText,
    this.errorMessage,
    this.resetHistory = const [],
  });

  bool get hasResetsLeft => resetsUsedToday < dailyResetLimit;

  ResetState copyWith({
    ResetStatus? status,
    String? trigger,
    List<String>? emotions,
    List<String>? selectedEmotions,
    int? resetsUsedToday,
    int? dailyResetLimit,
    int? totalReset,
    String? reframeText,
    String? nextActionText,
    String? errorMessage,
    List<ResetHistoryItem>? resetHistory,
  }) {
    return ResetState(
      status: status ?? this.status,
      trigger: trigger ?? this.trigger,
      emotions: emotions ?? this.emotions,
      selectedEmotions: selectedEmotions ?? this.selectedEmotions,
      resetsUsedToday: resetsUsedToday ?? this.resetsUsedToday,
      dailyResetLimit: dailyResetLimit ?? this.dailyResetLimit,
      totalReset: totalReset ?? this.totalReset,
      reframeText: reframeText ?? this.reframeText,
      nextActionText: nextActionText ?? this.nextActionText,
      errorMessage: errorMessage ?? this.errorMessage,
      resetHistory: resetHistory ?? this.resetHistory,
    );
  }
}
