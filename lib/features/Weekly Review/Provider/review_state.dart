import 'package:unflappable/features/Weekly%20Review/Model/review_model.dart';

class WeeklyReviewState {
  final bool showAddScreen;
  final WeeklyReviewData draft;
  final WeeklyReviewData? saved;
  final bool isLoading;
  final WeeklySummary summary;

  const WeeklyReviewState({
    this.showAddScreen = false,
    this.draft = const WeeklyReviewData(),
    this.saved,
    this.isLoading = false,
    this.summary = const WeeklySummary(),
  });

  bool get hasSavedReview => saved != null && saved!.hasAnyEntry;

  WeeklyReviewState copyWith({
    bool? showAddScreen,
    WeeklyReviewData? draft,
    WeeklyReviewData? saved,
    bool? isLoading,
    bool clearSaved = false,
  }) => WeeklyReviewState(
    showAddScreen: showAddScreen ?? this.showAddScreen,
    draft: draft ?? this.draft,
    saved: clearSaved ? null : (saved ?? this.saved),
    isLoading: isLoading ?? this.isLoading,
    summary: summary,
  );
}
