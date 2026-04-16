class WeeklyReviewData {
  final String id;
  final String biggestWin;
  final String biggestMiss;
  final String causeOfDrift;
  final String oneShiftNextWeek;
  final DateTime? createdAt;

  const WeeklyReviewData({
    this.id = '',
    this.biggestWin = '',
    this.biggestMiss = '',
    this.causeOfDrift = '',
    this.oneShiftNextWeek = '',
    this.createdAt,
  });

  factory WeeklyReviewData.fromJson(Map<String, dynamic> json) =>
      WeeklyReviewData(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        biggestWin: (json['biggestWin'] ?? '').toString(),
        biggestMiss: (json['biggestMiss'] ?? '').toString(),
        causeOfDrift: (json['causeOfDrift'] ?? '').toString(),
        oneShiftNextWeek:
            (json['oneShiftForNextWeek'] ?? json['oneShiftNextWeek'] ?? '')
                .toString(),
        createdAt: DateTime.tryParse(
          (json['createdAt'] ?? json['updatedAt'] ?? '').toString(),
        ),
      );

  bool get hasAnyEntry =>
      biggestWin.isNotEmpty ||
      biggestMiss.isNotEmpty ||
      causeOfDrift.isNotEmpty ||
      oneShiftNextWeek.isNotEmpty;

  WeeklyReviewData copyWith({
    String? id,
    String? biggestWin,
    String? biggestMiss,
    String? causeOfDrift,
    String? oneShiftNextWeek,
    DateTime? createdAt,
  }) => WeeklyReviewData(
    id: id ?? this.id,
    biggestWin: biggestWin ?? this.biggestWin,
    biggestMiss: biggestMiss ?? this.biggestMiss,
    causeOfDrift: causeOfDrift ?? this.causeOfDrift,
    oneShiftNextWeek: oneShiftNextWeek ?? this.oneShiftNextWeek,
    createdAt: createdAt ?? this.createdAt,
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
