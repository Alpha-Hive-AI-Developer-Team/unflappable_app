import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Weekly%20Review/Model/review_model.dart';
import 'package:unflappable/features/Weekly%20Review/Provider/review_state.dart';

class WeeklyReviewNotifier extends StateNotifier<WeeklyReviewState> {
  WeeklyReviewNotifier() : super(const WeeklyReviewState());

  void openAddScreen() => state = state.copyWith(
    showAddScreen: true,
    draft: const WeeklyReviewData(),
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
    state = state.copyWith(isLoading: true);
    // TODO: persist to repository
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      isLoading: false,
      saved: state.draft,
      showAddScreen: false,
    );
  }
}

final weeklyReviewProvider =
    StateNotifierProvider<WeeklyReviewNotifier, WeeklyReviewState>(
      (_) => WeeklyReviewNotifier(),
    );
