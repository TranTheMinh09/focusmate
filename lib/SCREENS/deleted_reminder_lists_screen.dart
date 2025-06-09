import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder_list.dart';
import '../MODELS/reminder.dart';

class DeletedReminderListsScreen extends StatefulWidget {
  const DeletedReminderListsScreen({super.key});

  @override
  State<DeletedReminderListsScreen> createState() => _DeletedReminderListsScreenState();
}

class _DeletedReminderListsScreenState extends State<DeletedReminderListsScreen> {
  late Box<ReminderList> deletedListBox;
  late Box<ReminderList> reminderListBox;

  List<ReminderList> selectedLists = [];
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    deletedListBox = Hive.box<ReminderList>('deletedReminderLists');
    reminderListBox = Hive.box<ReminderList>('reminderLists');
  }

  Future<void> _restoreList(ReminderList list, {bool showDialogBox = true}) async {
    bool confirm = true;

    if (showDialogBox) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Khôi phục danh sách?'),
          content: Text('Bạn có muốn khôi phục danh sách "${list.name}" và toàn bộ lời nhắc trong đó không?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Khôi phục')),
          ],
        ),
      );
      confirm = result == true;
    }

    if (confirm) {
      final remindersBox = Hive.box<Reminder>('reminders');
      List<Reminder> restoredReminders = [];

      for (var oldReminder in list.reminders ?? []) {
        final newReminder = Reminder(
          title: oldReminder.title,
          note: oldReminder.note,
          dateTime: oldReminder.dateTime,
          isCompleted: oldReminder.isCompleted,
          listKey: null,
          priority: oldReminder.priority,
        );

        final key = await remindersBox.add(newReminder);
        final addedReminder = remindersBox.get(key);
        if (addedReminder != null) {
          restoredReminders.add(addedReminder);
        }

        await oldReminder.delete();
      }

      final newList = ReminderList(
        name: list.name,
        icon: list.icon,
        color: list.color,
      );

      newList.reminders = HiveList(remindersBox, objects: restoredReminders);

      final newListKey = await Hive.box<ReminderList>('reminderLists').add(newList);

      for (var reminder in restoredReminders) {
        reminder.listKey = newListKey;
        await reminder.save();
      }

      await list.delete();
      setState(() {});
    }
  }

  Future<void> _restoreSelectedLists() async {
    if (selectedLists.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục danh sách'),
        content: Text('Bạn có chắc chắn muốn khôi phục ${selectedLists.length} danh sách đã chọn không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Khôi phục')),
        ],
      ),
    );

    if (confirm == true) {
      for (var list in selectedLists) {
        await _restoreList(list, showDialogBox: false);
      }

      setState(() {
        selectedLists.clear();
        isSelecting = false;
      });
    }
  }

  Future<void> _deleteSelectedLists() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh sách'),
        content: Text('Bạn có chắc muốn xóa ${selectedLists.length} danh sách đã chọn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      for (var list in selectedLists) {
        await list.delete();
      }

      setState(() {
        selectedLists.clear();
        isSelecting = false;
      });
    }
  }

  Future<void> _deleteAllLists() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ danh sách đã bị xóa không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa tất cả')),
        ],
      ),
    );

    if (confirm == true) {
      for (var list in deletedListBox.values) {
        await list.delete();
      }

      setState(() {
        selectedLists.clear();
        isSelecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deletedLists = deletedListBox.values.toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đã xóa gần đây'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'select') {
                  setState(() {
                    isSelecting = true;
                  });
                } else if (value == 'delete_all') {
                  _deleteAllLists();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'select', child: Text('Chọn danh sách')),
                const PopupMenuItem(value: 'delete_all', child: Text('Xóa tất cả')),
              ],
            ),
          ],
        ),
        body: deletedLists.isEmpty
            ? const Center(
                child: Text(
                  'Không có danh sách nào bị xóa.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.separated(
                itemCount: deletedLists.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final list = deletedLists[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(list.color),
                      child: Icon(IconData(list.icon, fontFamily: 'MaterialIcons'), color: Colors.white),
                    ),
                    title: Text(
                      list.name,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                    trailing: isSelecting
                        ? Checkbox(
                            value: selectedLists.contains(list),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedLists.add(list);
                                } else {
                                  selectedLists.remove(list);
                                }
                              });
                            },
                          )
                        : null,
                    onTap: isSelecting
                        ? () {
                            setState(() {
                              if (selectedLists.contains(list)) {
                                selectedLists.remove(list);
                              } else {
                                selectedLists.add(list);
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
                      onPressed: _restoreSelectedLists,
                      child: const Text('Khôi phục đã chọn', style: TextStyle(color: Colors.green)),
                    ),
                    TextButton(
                      onPressed: _deleteSelectedLists,
                      child: const Text('Xóa đã chọn', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
