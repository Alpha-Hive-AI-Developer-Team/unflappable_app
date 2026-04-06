import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Home/model/mission.dart';
import 'package:unflappable/features/Home/model/mission_task.dart';

const int kMaxTasks = 3;

class NewMissionState {
  final String objective;
  final List<String> tasks;

  const NewMissionState({this.objective = '', this.tasks = const []});

  bool get canAddTask => tasks.length < kMaxTasks;
  bool get canSubmit => objective.trim().isNotEmpty && tasks.isNotEmpty;
  int get taskCount => tasks.length;

  NewMissionState copyWith({String? objective, List<String>? tasks}) =>
      NewMissionState(
        objective: objective ?? this.objective,
        tasks: tasks ?? this.tasks,
      );
}

class NewMissionNotifier extends StateNotifier<NewMissionState> {
  NewMissionNotifier() : super(const NewMissionState());

  void setObjective(String v) => state = state.copyWith(objective: v);

  void addTask(String title) {
    // Only add to provider state when title is non-empty
    if (title.trim().isEmpty) return;
    if (state.tasks.length >= kMaxTasks) return;
    state = state.copyWith(tasks: [...state.tasks, title.trim()]);
  }

  void updateTask(int index, String title) {
    if (index < 0 || index >= state.tasks.length) return;
    final updated = List<String>.from(state.tasks);
    updated[index] = title;
    state = state.copyWith(tasks: updated);
  }

  void removeTask(int index) {
    if (index < 0 || index >= state.tasks.length) return;
    final updated = List<String>.from(state.tasks)..removeAt(index);
    state = state.copyWith(tasks: updated);
  }

  Mission buildMission() {
    return Mission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      objective: state.objective,
      tasks: state.tasks
          .asMap()
          .entries
          .map((e) => MissionTask(id: '${e.key}', title: e.value))
          .toList(),
    );
  }

  void reset() => state = const NewMissionState();
}

final newMissionProvider =
    StateNotifierProvider.autoDispose<NewMissionNotifier, NewMissionState>(
      (_) => NewMissionNotifier(),
    );
