import 'package:unflappable/features/Home/model/mission_task.dart';

class Mission {
  final String id;
  final String objective;
  final List<MissionTask> tasks;
  final bool isDone;
  final DateTime? date;

  const Mission({
    required this.id,
    required this.objective,
    required this.tasks,
    this.isDone = false,
    this.date,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    final rawTasks = json['tasks'];
    final dateRaw = json['date'] ?? json['createdAt'] ?? json['updatedAt'] ?? json['timestamp'];
    final parsedDate = dateRaw is DateTime
        ? dateRaw
        : DateTime.tryParse(dateRaw?.toString() ?? '');

    return Mission(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      objective: (json['objective'] ?? json['title'] ?? '').toString(),
      tasks: rawTasks is List
          ? rawTasks
                .whereType<Map>()
                .map(
                  (task) => MissionTask.fromJson(Map<String, dynamic>.from(task)),
                )
                .toList()
          : const [],
      isDone:
          json['isDone'] == true ||
          json['completed'] == true ||
          json['isCompleted'] == true,
      date: parsedDate,
    );
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
  bool get isAllCompleted => tasks.isNotEmpty && completedCount == tasks.length;

  Mission copyWith({
    String? id,
    String? objective,
    List<MissionTask>? tasks,
    bool? isDone,
    DateTime? date,
  }) => Mission(
    id: id ?? this.id,
    objective: objective ?? this.objective,
    tasks: tasks ?? this.tasks,
    isDone: isDone ?? this.isDone,
    date: date ?? this.date,
  );
}
