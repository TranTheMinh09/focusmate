class ReminderDetailManager {
  static int? currentReminderDetailId;
  static Map<int, bool> reminderCompletionStatus = {};  // Lưu trạng thái hoàn thành của từng lời nhắc

  static bool isReminderCompleted(int reminderId) {
    return reminderCompletionStatus[reminderId] ?? false;
  }

  static void markReminderCompleted(int reminderId) {
    reminderCompletionStatus[reminderId] = true;
  }
}
