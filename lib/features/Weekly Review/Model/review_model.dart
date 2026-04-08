class WeeklyReviewData {
  final String biggestWin;
  final String biggestMiss;
  final String causeOfDrift;
  final String oneShiftNextWeek;

  const WeeklyReviewData({
    this.biggestWin = '',
    this.biggestMiss = '',
    this.causeOfDrift = '',
    this.oneShiftNextWeek = '',
  });

  bool get hasAnyEntry =>
      biggestWin.isNotEmpty ||
      biggestMiss.isNotEmpty ||
      causeOfDrift.isNotEmpty ||
      oneShiftNextWeek.isNotEmpty;

  WeeklyReviewData copyWith({
    String? biggestWin,
    String? biggestMiss,
    String? causeOfDrift,
    String? oneShiftNextWeek,
  }) => WeeklyReviewData(
    biggestWin: biggestWin ?? this.biggestWin,
    biggestMiss: biggestMiss ?? this.biggestMiss,
    causeOfDrift: causeOfDrift ?? this.causeOfDrift,
    oneShiftNextWeek: oneShiftNextWeek ?? this.oneShiftNextWeek,
  );
}

class WeeklySummary {
  final int completedActions;
  final int plannedActions;
  final String strongestPattern;
  final String mainAdjustment;

  const WeeklySummary({
    this.completedActions = 4,
    this.plannedActions = 6,
    this.strongestPattern =
        'You are strongest when you start with visible work early.',
    this.mainAdjustment =
        'Protect the first 90 minutes for deep work next week.',
  });
}
