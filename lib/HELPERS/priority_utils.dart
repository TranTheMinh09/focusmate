import '../MODELS/reminder.dart';

String getPriorityLabel(Priority priority) {
  switch (priority) {
    case Priority.low:
      return 'Thấp';
    case Priority.medium:
      return 'Trung bình';
    case Priority.high:
      return 'Cao';
    default:
      return 'Không có';
  }
}
