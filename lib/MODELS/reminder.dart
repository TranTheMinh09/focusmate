import 'package:hive/hive.dart';

part 'reminder.g.dart'; // ⚠️ Dùng để Hive tự sinh file adapter - flutter pub run build_runner build --delete-conflicting-outputs

// 📦 Enum biểu diễn mức độ ưu tiên
@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  none, // Không ưu tiên
  @HiveField(1)
  low, // Ưu tiên thấp
  @HiveField(2)
  medium, // Ưu tiên trung bình
  @HiveField(3)
  high, // Ưu tiên cao
}

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  int? id; // ID duy nhất cho mỗi lời nhắc

  @HiveField(1)
  String title; // Tiêu đề lời nhắc

  @HiveField(2)
  String note; // Ghi chú chi tiết

  @HiveField(3)
  DateTime dateTime; // Thời gian nhắc

  @HiveField(4)
  Priority priority; // Mức độ ưu tiên

  @HiveField(5)
  bool isCompleted; // Đã hoàn thành hay chưa

  @HiveField(6)
  int? listKey; // Chỉ lưu key của danh sách

  @HiveField(7)
  int? earlyReminderMillis; // 👉 Lưu số milliseconds của Duration

  @HiveField(8)
  String repeatOption; // 'Không', 'Hàng ngày', v.v.

  @HiveField(9)
  int? customRepeatFrequency; // ví dụ: 2 (mỗi 2 đơn vị)

  @HiveField(10)
  String? customRepeatUnit; // ví dụ: 'ngày', 'tuần', 'tháng'

  // ✅ Getter & setter để làm việc với Duration như bình thường
  Duration? get earlyReminder => earlyReminderMillis != null
      ? Duration(milliseconds: earlyReminderMillis!)
      : null;

  set earlyReminder(Duration? value) =>
      earlyReminderMillis = value?.inMilliseconds;

  Reminder({
    this.id, // id có thể null khi tạo
    required this.title,
    required this.note,
    required this.dateTime,
    this.priority = Priority.none,
    this.isCompleted = false,
    required this.listKey,
    Duration? earlyReminder, // 👈 Dùng Duration bên ngoài constructor
    this.repeatOption = 'Không',
    this.customRepeatFrequency,
    this.customRepeatUnit,
  }) {
    this.earlyReminder = earlyReminder; // 👈 Gán vào setter
  }
}
