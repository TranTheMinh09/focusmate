import '../MODELS/reminder.dart';


DateTime? calculateNextOccurrence(Reminder reminder) {
  if (reminder.repeatOption == 'Không') return null;

  final base = reminder.dateTime;
  Duration? interval;

  switch (reminder.repeatOption) {
    case 'Hàng ngày':
      interval = const Duration(days: 1);
      break;
    case 'Ngày thường':
      DateTime next = base.add(const Duration(days: 1));
      while (next.weekday >= 6) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    case 'Cuối tuần':
      DateTime next = base.add(const Duration(days: 1));
      while (next.weekday < 6) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    case 'Hàng tuần':
      interval = const Duration(days: 7);
      break;
    case 'Hai tuần một lần':
      interval = const Duration(days: 14);
      break;
    case 'Hàng tháng':
      return DateTime(base.year, base.month + 1, base.day, base.hour, base.minute);
    case 'Mỗi 3 tháng':
      return DateTime(base.year, base.month + 3, base.day, base.hour, base.minute);
    case 'Mỗi 6 tháng':
      return DateTime(base.year, base.month + 6, base.day, base.hour, base.minute);
    case 'Hàng năm':
      return DateTime(base.year + 1, base.month, base.day, base.hour, base.minute);
    case 'Tùy chỉnh':
      if (reminder.customRepeatFrequency == null || reminder.customRepeatUnit == null) return null;
      switch (reminder.customRepeatUnit) {
        case 'ngày':
          interval = Duration(days: reminder.customRepeatFrequency!);
          break;
        case 'tuần':
          interval = Duration(days: reminder.customRepeatFrequency! * 7);
          break;
        case 'tháng':
          return DateTime(base.year, base.month + reminder.customRepeatFrequency!,
              base.day, base.hour, base.minute);
        case 'năm':
          return DateTime(base.year + reminder.customRepeatFrequency!,
              base.month, base.day, base.hour, base.minute);
      }
      break;
  }

  return interval != null ? base.add(interval) : null;
}
