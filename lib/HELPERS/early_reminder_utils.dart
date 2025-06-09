DateTime? calculateEarlyReminderTime({
  required DateTime baseTime,
  required String earlyReminderLabel,
  required int customValue,
  required String customUnit,
}) {
  Duration offset;

  switch (earlyReminderLabel) {
    case 'Trước 5 phút':
      offset = const Duration(minutes: 5);
      break;
    case 'Trước 15 phút':
      offset = const Duration(minutes: 15);
      break;
    case 'Trước 30 phút':
      offset = const Duration(minutes: 30);
      break;
    case 'Trước 1 giờ':
      offset = const Duration(hours: 1);
      break;
    case 'Trước 2 giờ':
      offset = const Duration(hours: 2);
      break;
    case 'Trước 1 ngày':
      offset = const Duration(days: 1);
      break;
    case 'Trước 2 ngày':
      offset = const Duration(days: 2);
      break;
    case 'Trước 1 tuần':
      offset = const Duration(days: 7);
      break;
    case 'Trước 1 tháng':
      offset = const Duration(days: 30);
      break;
    case 'Tuỳ chỉnh':
      offset = _getCustomDuration(customValue, customUnit);
      break;
    case 'Không có':
      return null; // Không đặt lời nhắc sớm
    default:
      return null;
  }

  final reminderTime = baseTime.subtract(offset);
  return reminderTime.isBefore(DateTime.now()) ? null : reminderTime;
}

Duration _getCustomDuration(int value, String unit) {
  switch (unit) {
    case 'phút':
      return Duration(minutes: value);
    case 'giờ':
      return Duration(hours: value);
    case 'ngày':
      return Duration(days: value);
    case 'tuần':
      return Duration(days: value * 7);
    case 'tháng':
      return Duration(days: value * 30);
    default:
      return Duration.zero;
  }
}
