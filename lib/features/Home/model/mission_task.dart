class MissionTask {
  final String id;
  final String title;
  final bool isCompleted;

  const MissionTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  MissionTask copyWith({String? title, bool? isCompleted}) => MissionTask(
    id: id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
