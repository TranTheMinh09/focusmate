import 'package:hive/hive.dart';
import '../MODELS/reminder.dart';
import 'notification_helper.dart';
import 'repeat_utils.dart';

Future<void> handleRepeatingReminders() async {
  final box = await Hive.openBox<Reminder>('reminders');
  final now = DateTime.now();

  for (var reminder in box.values) {
    if (reminder.repeatOption != 'Không') {
      final nextTime = calculateNextOccurrence(reminder);

      if (nextTime != null &&
          reminder.dateTime.isBefore(now) &&
          reminder.isCompleted) {
        // Cập nhật lời nhắc
        reminder.dateTime = nextTime;
        reminder.isCompleted = false;

        // Cập nhật early reminder nếu có
        if (reminder.earlyReminder != null) {
          final earlyTime = nextTime.subtract(reminder.earlyReminder!);
          reminder.earlyReminder = nextTime.difference(earlyTime);
        }

        await reminder.save();

        // Tính ID cơ bản để đảm bảo không trùng nhau
        final baseId = (reminder.id ?? reminder.key ?? 0) + 1000;

        // Gửi lại thông báo chính
        await scheduleNotification(
          id: baseId,
          title: '[Lặp lại] ${reminder.title}',
          body: 'Đến giờ nhắc lại: ${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}',
          scheduledDate: nextTime,
          payload: reminder.key.toString(),
        );

        // Gửi lại nhắc sớm nếu có
        if (reminder.earlyReminder != null) {
          final earlyTime = nextTime.subtract(reminder.earlyReminder!);
          await scheduleNotification(
            id: baseId + 999,
            title: '[Nhắc sớm] ${reminder.title}',
            body: 'Sắp đến giờ nhắc lúc ${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}',
            scheduledDate: earlyTime,
            payload: reminder.key.toString(),
          );
        }
      }
    }
  }
}
