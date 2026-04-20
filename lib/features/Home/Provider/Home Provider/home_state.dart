import 'package:unflappable/features/Home/model/mission.dart';

class HomeState {
  final int dayStreak;
  final int longestStreak;
  final int missionCount;
  final int totalTasks;
  final int completedTasks;
  final int totalResetToday;
  final int totalResets;
  final String taskCompletionLabel;
  final String taskCompletionSubtitle;
  final double taskCompletionPercentage;
  final String totalResetsLabel;
  final String totalResetsSubtitle;
  final double totalResetsPercentage;
  final Mission? activeMission;
  final bool isLoading;
  final bool isCreatingMission;
  final bool hasLoaded;
  final String? errorMessage;
  final String? activeTaskId;
  final bool isRefreshingCompletedMission;

  const HomeState({
    this.dayStreak = 0,
    this.longestStreak = 0,
    this.missionCount = 0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.totalResetToday = 0,
    this.totalResets = 0,
    this.taskCompletionLabel = 'Task Completion',
    this.taskCompletionSubtitle = '0 of 0 tasks done',
    this.taskCompletionPercentage = 0,
    this.totalResetsLabel = 'Total Resets',
    this.totalResetsSubtitle = 'Moments of recovery',
    this.totalResetsPercentage = 0,
    this.activeMission,
    this.isLoading = false,
    this.isCreatingMission = false,
    this.hasLoaded = false,
    this.errorMessage,
    this.activeTaskId,
    this.isRefreshingCompletedMission = false,
  });

  bool get hasMission => activeMission != null;

  double get completionRate =>
      totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  HomeState copyWith({
    int? dayStreak,
    int? longestStreak,
    int? missionCount,
    int? totalTasks,
    int? completedTasks,
    int? totalResetToday,
    int? totalResets,
    String? taskCompletionLabel,
    String? taskCompletionSubtitle,
    double? taskCompletionPercentage,
    String? totalResetsLabel,
    String? totalResetsSubtitle,
    double? totalResetsPercentage,
    Mission? activeMission,
    bool? isLoading,
    bool? isCreatingMission,
    bool? hasLoaded,
    String? errorMessage,
    String? activeTaskId,
    bool? isRefreshingCompletedMission,
    bool clearMission = false,
    bool clearError = false,
    bool clearActiveTask = false,
  }) => HomeState(
    dayStreak: dayStreak ?? this.dayStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    missionCount: missionCount ?? this.missionCount,
    totalTasks: totalTasks ?? this.totalTasks,
    completedTasks: completedTasks ?? this.completedTasks,
    totalResetToday: totalResetToday ?? this.totalResetToday,
    totalResets: totalResets ?? this.totalResets,
    taskCompletionLabel: taskCompletionLabel ?? this.taskCompletionLabel,
    taskCompletionSubtitle:
        taskCompletionSubtitle ?? this.taskCompletionSubtitle,
    taskCompletionPercentage:
        taskCompletionPercentage ?? this.taskCompletionPercentage,
    totalResetsLabel: totalResetsLabel ?? this.totalResetsLabel,
    totalResetsSubtitle: totalResetsSubtitle ?? this.totalResetsSubtitle,
    totalResetsPercentage: totalResetsPercentage ?? this.totalResetsPercentage,
    activeMission: clearMission ? null : (activeMission ?? this.activeMission),
    isLoading: isLoading ?? this.isLoading,
    isCreatingMission: isCreatingMission ?? this.isCreatingMission,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    activeTaskId: clearActiveTask ? null : (activeTaskId ?? this.activeTaskId),
    isRefreshingCompletedMission:
        isRefreshingCompletedMission ?? this.isRefreshingCompletedMission,
  );
}
