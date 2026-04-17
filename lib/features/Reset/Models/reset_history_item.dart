class ResetHistoryItem {
  final String trigger;
  final List<String> emotions;
  final String reframeText;
  final String nextActionText;
  final DateTime timestamp;

  const ResetHistoryItem({
    required this.trigger,
    required this.emotions,
    required this.reframeText,
    required this.nextActionText,
    required this.timestamp,
  });

  factory ResetHistoryItem.fromJson(Map<String, dynamic> json) {
    final emotionsValue =
        json['emotions'] ?? json['feeling'] ?? json['feelings'];
    final emotions = _parseEmotions(emotionsValue);

    final timestampValue =
        json['timestamp'] ?? json['createdAt'] ?? json['created_at'];
    final timestamp = _parseTimestamp(timestampValue);

    return ResetHistoryItem(
      trigger: json['trigger'] ?? json['feeling'] ?? json['title'] ?? 'Unknown',
      emotions: emotions,
      reframeText:
          json['reframeText'] ?? json['reframe'] ?? json['reframe_text'] ?? '',
      nextActionText:
          json['nextActionText'] ??
          json['nextAction'] ??
          json['next_action'] ??
          '',
      timestamp: timestamp,
    );
  }

  static List<String> _parseEmotions(dynamic value) {
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Format timestamp as readable string (e.g., "Today at 2:30 PM")
  String get formattedTime {
    final now = DateTime.now();
    final isToday =
        timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;

    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    if (isToday) {
      return 'Today at $timeStr';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day;

    if (isYesterday) {
      return 'Yesterday at $timeStr';
    }

    // Format as "Dec 15 at 2:30 PM"
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthStr = months[timestamp.month - 1];
    return '$monthStr ${timestamp.day} at $timeStr';
  }

  /// Get emotions as comma-separated string
  String get emotionsDisplay => emotions.join(', ');
}
