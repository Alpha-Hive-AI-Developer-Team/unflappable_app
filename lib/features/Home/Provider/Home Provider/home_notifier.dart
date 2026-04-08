import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Home/Provider/Home%20Provider/home_state.dart';
import 'package:unflappable/features/Home/model/mission.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState(dayStreak: 12, missionCount: 2));

  void setMission(Mission mission) {
    state = state.copyWith(activeMission: mission);
  }

  void toggleTask(String taskId) {
    final mission = state.activeMission;
    if (mission == null) return;

    final updatedTasks = mission.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(isCompleted: !t.isCompleted);
      return t;
    }).toList();

    state = state.copyWith(
      activeMission: mission.copyWith(tasks: updatedTasks),
    );
  }

  void markMissionDone() {
    final mission = state.activeMission;
    if (mission == null) return;
    state = state.copyWith(activeMission: mission.copyWith(isDone: true));
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (_) => HomeNotifier(),
);
