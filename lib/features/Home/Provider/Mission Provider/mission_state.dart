const int kMaxTasks = 3;
const int kMaxTaskTitleLength = 100;

class NewMissionState {
  final String objective;
  final List<String> tasks;

  const NewMissionState({this.objective = '', this.tasks = const []});

  bool get canAddTask => tasks.length < kMaxTasks;
    bool get hasInvalidTaskTitle =>
      tasks.any((task) => task.length > kMaxTaskTitleLength);
    bool get canSubmit =>
      objective.trim().isNotEmpty &&
      tasks.isNotEmpty &&
      !hasInvalidTaskTitle;
  int get taskCount => tasks.length;

  NewMissionState copyWith({String? objective, List<String>? tasks}) =>
      NewMissionState(
        objective: objective ?? this.objective,
        tasks: tasks ?? this.tasks,
      );
}
