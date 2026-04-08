import 'package:unflappable/features/Home/model/mission.dart';

class HomeState {
  final int dayStreak;
  final int missionCount;
  final int totalTasks;
  final int completedTasks;
  final int totalResets;
  final Mission? activeMission;

  const HomeState({
    this.dayStreak = 0,
    this.missionCount = 0,
    this.totalTasks = 12,
    this.completedTasks = 9,
    this.totalResets = 3,
    this.activeMission,
  });

  bool get hasMission => activeMission != null;

  double get completionRate =>
      totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  HomeState copyWith({
    int? dayStreak,
    int? missionCount,
    int? totalTasks,
    int? completedTasks,
    int? totalResets,
    Mission? activeMission,
    bool clearMission = false,
  }) => HomeState(
    dayStreak: dayStreak ?? this.dayStreak,
    missionCount: missionCount ?? this.missionCount,
    totalTasks: totalTasks ?? this.totalTasks,
    completedTasks: completedTasks ?? this.completedTasks,
    totalResets: totalResets ?? this.totalResets,
    activeMission: clearMission ? null : (activeMission ?? this.activeMission),
  );
}
