// lib/features/Home/Provider/Mission Provider/mission_history_state.dart

import 'package:unflappable/features/Home/model/mission.dart';

class MissionHistoryState {
  final List<Mission> missions;
  final bool isLoading;
  final String? errorMessage;

  const MissionHistoryState({
    this.missions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MissionHistoryState copyWith({
    List<Mission>? missions,
    bool? isLoading,
    String? errorMessage,
  }) => MissionHistoryState(
    missions: missions ?? this.missions,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage,
  );
}
