import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder.dart';
import '../helpers/reminder_detail_manager.dart'; // ⬅️ thêm dòng này

class ReminderDetailScreen extends StatefulWidget {
  final int reminderId;

  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  Future<Reminder?> _loadReminder() async {
    final reminderBox = await Hive.openBox<Reminder>('reminders');
    return reminderBox.get(widget.reminderId);
  }

  @override
  void initState() {
    super.initState();
    ReminderDetailManager.currentReminderDetailId = widget.reminderId;
  }

  @override
  void dispose() {
    if (ReminderDetailManager.currentReminderDetailId == widget.reminderId) {
      ReminderDetailManager.currentReminderDetailId = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lời nhắc')),
      body: FutureBuilder<Reminder?>(
        future: _loadReminder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminder = snapshot.data;
          if (reminder == null) {
            return const Center(child: Text('Không tìm thấy lời nhắc'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  reminder.note.trim().isNotEmpty == true
                      ? reminder.note
                      : '(Không có ghi chú)',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      formatDateTime(reminder.dateTime),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year – $hour:$minute';
  }
}
