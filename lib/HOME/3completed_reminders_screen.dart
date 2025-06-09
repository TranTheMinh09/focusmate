import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../MODELS/reminder.dart';

class CompletedRemindersScreen extends StatefulWidget {
  const CompletedRemindersScreen({super.key});

  @override
  State<CompletedRemindersScreen> createState() => _CompletedRemindersScreenState();
}

class _CompletedRemindersScreenState extends State<CompletedRemindersScreen> {
  List<Reminder> completedReminders = [];
  List<Reminder> selectedReminders = [];
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    _loadCompletedReminders();
  }

  void _loadCompletedReminders() {
    final reminderBox = Hive.box<Reminder>('reminders');
    completedReminders = reminderBox.values.where((r) => r.isCompleted).toList();
    setState(() {});
  }

  Future<void> _uncompleteSelected() async {
    for (var reminder in selectedReminders) {
      reminder.isCompleted = false;
      await reminder.save();
    }
    setState(() {
      isSelecting = false;
      selectedReminders.clear();
      _loadCompletedReminders();
    });
  }

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lời nhắc'),
        content: Text('Bạn có chắc muốn xóa ${selectedReminders.length} lời nhắc đã chọn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      for (var reminder in selectedReminders) {
        await reminder.delete();
      }
      setState(() {
        isSelecting = false;
        selectedReminders.clear();
        _loadCompletedReminders();
      });
    }
  }

  Future<void> _deleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả'),
        content: const Text('Bạn có chắc muốn xóa tất cả lời nhắc đã hoàn tất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa tất cả')),
        ],
      ),
    );

    if (confirm == true) {
      for (var reminder in completedReminders) {
        await reminder.delete();
      }
      setState(() {
        selectedReminders.clear();
        isSelecting = false;
        _loadCompletedReminders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đã hoàn tất'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'select') {
                setState(() {
                  isSelecting = true;
                });
              } else if (value == 'delete_all') {
                _deleteAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'select', child: Text('Chọn lời nhắc')),
              const PopupMenuItem(value: 'delete_all', child: Text('Xóa tất cả')),
            ],
          ),
        ],
      ),
      body: completedReminders.isEmpty
          ? const Center(
              child: Text(
                'Không có lời nhắc đã hoàn tất.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: completedReminders.length,
              itemBuilder: (context, index) {
                final reminder = completedReminders[index];
                final formattedDateTime =
                    DateFormat('dd/MM/yyyy – HH:mm').format(reminder.dateTime);

                String priorityText;
                Color priorityColor;

                switch (reminder.priority) {
                  case Priority.high:
                    priorityText = 'Khẩn cấp';
                    priorityColor = Colors.red;
                    break;
                  case Priority.medium:
                    priorityText = 'Quan trọng';
                    priorityColor = Colors.orange;
                    break;
                  case Priority.low:
                    priorityText = 'Thông thường';
                    priorityColor = Colors.green;
                    break;
                  default:
                    priorityText = '';
                    priorityColor = Colors.grey;
                }

                return ListTile(
                  leading: const Icon(CupertinoIcons.check_mark_circled_solid,
                      color: CupertinoColors.systemGreen),
                  title: Text(reminder.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formattedDateTime,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            decoration: TextDecoration.none,
                          )),
                      if (reminder.priority != Priority.none)
                        Text(priorityText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: priorityColor,
                              decoration: TextDecoration.none,
                            )),
                    ],
                  ),
                  trailing: isSelecting
                      ? Checkbox(
                          value: selectedReminders.contains(reminder),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedReminders.add(reminder);
                              } else {
                                selectedReminders.remove(reminder);
                              }
                            });
                          },
                        )
                      : null,
                  onTap: isSelecting
                      ? () {
                          setState(() {
                            if (selectedReminders.contains(reminder)) {
                              selectedReminders.remove(reminder);
                            } else {
                              selectedReminders.add(reminder);
                            }
                          });
                        }
                      : null,
                );
              },
            ),
      bottomSheet: isSelecting
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: _uncompleteSelected,
                    child: const Text('Bỏ hoàn thành', style: TextStyle(color: Colors.green)),
                  ),
                  TextButton(
                    onPressed: _deleteSelected,
                    child: const Text('Xóa đã chọn', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}