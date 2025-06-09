import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
  String? payload,
  bool vibrate = false,
}) async {
  final tz.TZDateTime tzScheduledDate =
      tz.TZDateTime.from(scheduledDate, tz.local);
  final now = tz.TZDateTime.now(tz.local);

  if (tzScheduledDate.isBefore(now)) {
    return; // Không đặt thông báo nếu đã qua
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tzScheduledDate,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Lời nhắc',
        channelDescription: 'Thông báo lời nhắc cho FocusMate',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: vibrate,
        icon: 'ic_status_bar',
        vibrationPattern: vibrate
            ? Int64List.fromList([0, 1000, 500, 1000, 500, 1500])
            : null,
            // biểu tượng cho thanh trạng thái
        largeIcon: const DrawableResourceAndroidBitmap('ic_notification'),
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: payload ?? id.toString(),
  );
}

// ✅ Hàm mới: Đặt nhiều thông báo lặp lại nếu chưa hoàn thành
Future<void> scheduleRepeatingNotifications({
  required int baseId,
  required String title,
  required String body,
  required DateTime startTime,
  required Duration interval,
  required int repeatCount,
  required String payload,
}) async {
  for (int i = 0; i < repeatCount; i++) {
    final scheduledTime = startTime.add(interval * i);
    await scheduleNotification(
      id: baseId + i,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      payload: payload,
      vibrate: true,
    );
  }
}
