class MissionTask {
  final String id;
  final String title;
  final bool isCompleted;

  const MissionTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory MissionTask.fromJson(Map<String, dynamic> json) => MissionTask(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    title: (json['title'] ?? json['name'] ?? '').toString(),
    isCompleted:
        json['isCompleted'] == true ||
        json['completed'] == true ||
        json['done'] == true,
  );

  MissionTask copyWith({String? title, bool? isCompleted}) => MissionTask(
    id: id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
