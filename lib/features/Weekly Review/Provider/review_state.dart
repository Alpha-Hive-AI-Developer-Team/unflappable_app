import 'package:unflappable/features/Weekly%20Review/Model/review_model.dart';

const int kMaxWeeklyReviewFieldLength = 100;

const _keep = Object();

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
  // UW-40: per-field "required" validation messages shown on Add Review.
  final String? biggestWinError;
  final String? biggestMissError;
  final String? causeOfDriftError;
  final String? oneShiftError;

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
    this.biggestWinError,
    this.biggestMissError,
    this.causeOfDriftError,
    this.oneShiftError,
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
    Object? biggestWinError = _keep,
    Object? biggestMissError = _keep,
    Object? causeOfDriftError = _keep,
    Object? oneShiftError = _keep,
    bool clearFieldErrors = false,
  }) => WeeklyReviewState(
    showAddScreen: showAddScreen ?? this.showAddScreen,
    draft: draft ?? this.draft,
    saved: clearSaved ? null : (saved ?? this.saved),
    history: history ?? this.history,
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    successMessage: clearSuccess
        ? null
        : (successMessage ?? this.successMessage),
    summary: summary,
    biggestWinError: clearFieldErrors
        ? null
        : (biggestWinError == _keep
              ? this.biggestWinError
              : biggestWinError as String?),
    biggestMissError: clearFieldErrors
        ? null
        : (biggestMissError == _keep
              ? this.biggestMissError
              : biggestMissError as String?),
    causeOfDriftError: clearFieldErrors
        ? null
        : (causeOfDriftError == _keep
              ? this.causeOfDriftError
              : causeOfDriftError as String?),
    oneShiftError: clearFieldErrors
        ? null
        : (oneShiftError == _keep
              ? this.oneShiftError
              : oneShiftError as String?),
  );
}
