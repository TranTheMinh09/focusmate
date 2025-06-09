import 'package:hive/hive.dart';
import 'reminder.dart'; // import Reminder để dùng bên dưới

part 'reminder_list.g.dart'; // 🔁 Để Hive sinh file adapter

@HiveType(typeId: 2)
class ReminderList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  HiveList<Reminder>? reminders;

  @HiveField(2)
  int icon; // 🔹 icon lưu dưới dạng codePoint

  @HiveField(3)
  int color; // 🔹 màu lưu dưới dạng int từ Color.value

  ReminderList({
    required this.name,
    required this.icon,
    required this.color,
    this.reminders,
  });
}
