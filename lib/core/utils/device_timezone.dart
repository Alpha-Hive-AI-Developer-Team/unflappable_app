import 'package:flutter_timezone/flutter_timezone.dart';

/// UA-81: backend schedules reminders using the IANA timezone the app sends
/// it — without this, backend falls back to UTC and reminder times are off
/// by the user's UTC offset.
abstract final class DeviceTimezone {
  static Future<String?> current() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final name = info.identifier.trim();
      return name.isEmpty ? null : name;
    } catch (_) {
      return null;
    }
  }
}
