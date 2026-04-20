class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime receivedAt;
  final Map<String, dynamic> data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.receivedAt,
    required this.data,
  });

  bool get unread => !isRead;

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    DateTime? receivedAt,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      receivedAt: receivedAt ?? this.receivedAt,
      data: data ?? this.data,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'] ?? json['created_at'] ?? json['sentAt'];
    DateTime receivedAt = DateTime.now();
    if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      receivedAt = DateTime.tryParse(rawCreatedAt) ?? receivedAt;
    } else if (rawCreatedAt is int) {
      receivedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    }

    return AppNotification(
      id: json['id']?.toString() ?? json['notificationId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['notificationTitle']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      isRead: json['isRead'] == true || json['read'] == true || json['is_read'] == true,
      receivedAt: receivedAt,
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'] as Map)
          : <String, dynamic>{},
    );
  }
}
