import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive/hive.dart';

import 'HELPERS/hive_setup.dart';
import 'HOME/home_screen.dart';
import 'SCREENS/reminder_detail_screen.dart';
import 'HELPERS/reminder_detail_manager.dart';
import 'HELPERS/repeat_handler.dart';
import 'HELPERS/notification_helper.dart';
import 'MODELS/reminder.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

int? reminderIdFromNotification;

// 👉 CALLBACK CHẠY NỀN: Quét các reminder trễ và nhắc lại
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await setupHive();
    final box = await Hive.openBox<Reminder>('reminders');
    final now = DateTime.now();

    for (var reminder in box.values) {
      if (!reminder.isCompleted && reminder.dateTime.isBefore(now)) {
        await scheduleNotification(
          id: reminder.key.hashCode,
          title: "[Lời nhắc trễ]",
          body: "${reminder.title}\n${reminder.dateTime}",
          scheduledDate: now.add(const Duration(seconds: 3)),
          payload: reminder.key.toString(),
        );
      }
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupHive();
  tz.initializeTimeZones();
  await handleRepeatingReminders();

  // ⚙️ Khởi tạo Workmanager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "check-overdue-reminders",
    "checkOverdueTask",
    frequency: const Duration(minutes: 15),
  );

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  NotificationAppLaunchDetails? launchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  final initialPayload = launchDetails?.notificationResponse?.payload;
  reminderIdFromNotification = int.tryParse(initialPayload ?? '');

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      final id = int.tryParse(payload ?? '');
      if (id != null) {
        openReminderDetail(id);
      }
    },
  );

  if (await Permission.notification.isDenied) {
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      debugPrint('❌ Người dùng từ chối cấp quyền thông báo.');
    }
  }

  if (await Permission.scheduleExactAlarm.isDenied) {
    final status = await Permission.scheduleExactAlarm.request();
    if (!status.isGranted) {
      debugPrint('❌ Người dùng từ chối cấp quyền SCHEDULE_EXACT_ALARM.');
    }
  }

  runApp(MyApp(reminderId: reminderIdFromNotification));
}

class MyApp extends StatelessWidget {
  final int? reminderId;

  const MyApp({super.key, this.reminderId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FocusMate',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      initialRoute: reminderId != null ? '/reminder_detail' : '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/reminder_detail') {
          final id = settings.arguments as int? ?? reminderId;
          if (id != null) {
            return MaterialPageRoute(
              builder: (_) => ReminderDetailScreen(reminderId: id),
            );
          }
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      },
    );
  }
}

void openReminderDetail(int reminderId) {
  final currentContext = navigatorKey.currentContext;

  if (currentContext == null) return;

  if (ReminderDetailManager.currentReminderDetailId == reminderId) {
    return;
  }

  ReminderDetailManager.currentReminderDetailId = reminderId;

  if (ReminderDetailManager.currentReminderDetailId != null) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReminderDetailScreen(reminderId: reminderId),
      ),
    );
  } else {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ReminderDetailScreen(reminderId: reminderId),
      ),
    );
  }
}
