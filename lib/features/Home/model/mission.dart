import 'package:unflappable/features/Home/model/mission_task.dart';

class Mission {
  final String id;
  final String objective;
  final List<MissionTask> tasks;
  final bool isDone;

  const Mission({
    required this.id,
    required this.objective,
    required this.tasks,
    this.isDone = false,
  });

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
  bool get isAllCompleted => tasks.isNotEmpty && completedCount == tasks.length;

  Mission copyWith({
    String? objective,
    List<MissionTask>? tasks,
    bool? isDone,
  }) => Mission(
    id: id,
    objective: objective ?? this.objective,
    tasks: tasks ?? this.tasks,
    isDone: isDone ?? this.isDone,
  );
}
