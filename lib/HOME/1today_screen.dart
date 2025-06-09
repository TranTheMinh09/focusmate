import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder.dart';
import '../WIDGETS/reminder_checkbox.dart';
import 'package:intl/intl.dart';
import '../SCREENS/edit_reminder_screen.dart';
import '../SCREENS/reminder_detail_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() async {
    final remindersBox = await Hive.openBox<Reminder>('reminders');
    final now = DateTime.now();
    final todaysReminders = remindersBox.values.where((reminder) {
      final date = reminder.dateTime;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day &&
          !reminder.isCompleted;
    }).toList();

    setState(() {
      _reminders = todaysReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lời nhắc hôm nay'),
      ),
      child: SafeArea(
        child: _reminders.isEmpty
            ? const Center(
                child: Text(
                  'Không có lời nhắc hôm nay.',
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.systemGrey2,
                    decoration: TextDecoration.none,
                  ),
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return _buildReminderCard(reminder, () {
                    _loadReminders(); // refresh sau khi sửa hoặc xoá
                  });
                },
              ),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder, VoidCallback onUpdated) {
    final formattedDateTime =
        DateFormat('dd/MM/yyyy – HH:mm').format(reminder.dateTime);

    String priorityText;
    Color priorityColor;

    switch (reminder.priority) {
      case Priority.high:
        priorityText = 'Khẩn cấp';
        priorityColor = CupertinoColors.systemRed;
        break;
      case Priority.medium:
        priorityText = 'Quan trọng';
        priorityColor = CupertinoColors.systemOrange;
        break;
      case Priority.low:
        priorityText = 'Thông thường';
        priorityColor = CupertinoColors.systemGreen;
        break;
      default:
        priorityText = '';
        priorityColor = CupertinoColors.systemGrey;
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReminderDetailScreen(reminderId: reminder.key as int),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final itemWidth = totalWidth / 3;
            const itemHeight = 80.0;

            return Slidable(
              key: Key(reminder.key.toString()),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 2 / 3, // 2 hành động * 1/3 mỗi cái
                children: [
                  CustomSlidableAction(
                    onPressed: (_) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditReminderScreen(reminder: reminder),
                        ),
                      );
                      onUpdated();
                    },
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue,
                    child: SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: const Center(
                        child: Icon(Icons.edit, color: Colors.blue),
                      ),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (_) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Xác nhận xoá"),
                          content: const Text("Bạn có chắc muốn xoá lời nhắc này không?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Huỷ")),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Xoá",
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await reminder.delete();
                        onUpdated();
                      }
                    },
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: const Center(
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
              child: Container(
                height: itemHeight,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    ReminderCheckbox(
                      reminder: reminder,
                      onReminderUpdated: onUpdated,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.notifications_active,
                        color: CupertinoColors.systemBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.label,
                              decoration: TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDateTime,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          if (reminder.priority != Priority.none) ...[
                            const SizedBox(height: 4),
                            Text(
                              priorityText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: priorityColor,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}