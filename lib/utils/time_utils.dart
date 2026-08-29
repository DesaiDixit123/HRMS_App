import 'package:intl/intl.dart';

String convertTo24Hour(String? timeStr) {
  if (timeStr == null || timeStr.isEmpty || timeStr == '-') return '-';
  try {
    final cleaned = timeStr.replaceAll('am', 'AM').replaceAll('pm', 'PM').trim();
    if (!cleaned.contains('AM') && !cleaned.contains('PM')) {
      return timeStr;
    }
    final format12 = DateFormat('hh:mm a');
    final format24 = DateFormat('HH:mm');
    final dt = format12.parse(cleaned);
    return format24.format(dt);
  } catch (_) {
    try {
      final parts = timeStr.trim().split(RegExp(r'\s+'));
      if (parts.length == 2) {
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final min = timeParts[1];
        final isPm = parts[1].toUpperCase() == 'PM';
        if (isPm && hour < 12) {
          hour += 12;
        } else if (!isPm && hour == 12) {
          hour = 0;
        }
        return '${hour.toString().padLeft(2, '0')}:$min';
      }
    } catch (_) {}
    return timeStr;
  }
}
