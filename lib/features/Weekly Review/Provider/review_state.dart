import 'package:unflappable/features/Weekly%20Review/Model/review_model.dart';

class WeeklyReviewState {
  final bool showAddScreen;
  final WeeklyReviewData draft;
  final WeeklyReviewData? saved;
  final List<WeeklyReviewData> history;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;
  final String? successMessage;
  final WeeklySummary summary;

  const WeeklyReviewState({
    this.showAddScreen = false,
    this.draft = const WeeklyReviewData(),
    this.saved,
    this.history = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
    this.successMessage,
    this.summary = const WeeklySummary(),
  });

  bool get hasSavedReview => saved != null && saved!.hasAnyEntry;

  WeeklyReviewState copyWith({
    bool? showAddScreen,
    WeeklyReviewData? draft,
    WeeklyReviewData? saved,
    List<WeeklyReviewData>? history,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    String? successMessage,
    bool clearSaved = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) => WeeklyReviewState(
    showAddScreen: showAddScreen ?? this.showAddScreen,
    draft: draft ?? this.draft,
    saved: clearSaved ? null : (saved ?? this.saved),
    history: history ?? this.history,
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    successMessage:
        clearSuccess ? null : (successMessage ?? this.successMessage),
    summary: summary,
  );
}
