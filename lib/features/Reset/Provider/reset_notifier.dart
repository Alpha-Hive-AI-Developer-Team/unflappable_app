import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Reset/Models/reset_history_item.dart';
import 'package:unflappable/features/Reset/Provider/reset_state.dart';

class ResetNotifier extends StateNotifier<ResetState> {
  ResetNotifier() : super(const ResetState());

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

  // ── TODO: Replace with real API call ─────────────────────────────────────
  // Future<void> fetchEmotions() async {
  //   state = state.copyWith(status: ResetStatus.loading);
  //   try {
  //     final emotions = await _resetRepository.getEmotions();
  //     state = state.copyWith(
  //       status: ResetStatus.initial,
  //       emotions: emotions,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       status: ResetStatus.error,
  //       errorMessage: e.toString(),
  //     );
  //   }
  // }

  // ── Run Reset ─────────────────────────────────────────────────────────────

  Future<void> runReset() async {
    if (!state.hasResetsLeft) return;

    state = state.copyWith(status: ResetStatus.loading);

    try {
      // ── Simulated response (remove when API is ready) ──
      await Future.delayed(const Duration(milliseconds: 800));

      // Create a new reset history item
      final historyItem = ResetHistoryItem(
        trigger: state.trigger ?? 'Unknown',
        emotions: List<String>.from(state.selectedEmotions),
        reframeText: 'Delay is not rejection.',
        nextActionText:
            'Send a clean recap and ask for the next decision point.',
        timestamp: DateTime.now(),
      );

      // Add to history
      final updatedHistory = [historyItem, ...state.resetHistory];

      state = state.copyWith(
        status: ResetStatus.success,
        reframeText: 'Delay is not rejection.',
        nextActionText:
            'Send a clean recap and ask for the next decision point.',
        resetsUsedToday: state.resetsUsedToday + 1,
        totalReset: state.totalReset + 1,
        resetHistory: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        status: ResetStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Reset flow back to initial ────────────────────────────────────────────

  void resetFlow() {
    state = ResetState(
      resetsUsedToday: state.resetsUsedToday,
      totalReset: state.totalReset,
      dailyResetLimit: state.dailyResetLimit,
      isPro: state.isPro,
      emotions: state.emotions,
      resetHistory: state.resetHistory,
    );
  }

  void clearError() {
    state = state.copyWith(status: ResetStatus.initial, errorMessage: null);
  }
}
