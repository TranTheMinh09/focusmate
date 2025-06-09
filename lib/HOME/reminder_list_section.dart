import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../SCREENS/deleted_reminder_lists_screen.dart';
import '../ADD_REMINDER_LIST/edit_reminder_list_screen.dart';
import '../../../../MODELS/reminder_list.dart';
import '../SCREENS/reminders_of_list_screen.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder.dart';

class ReminderListSection extends StatelessWidget {
  final List<ReminderList> lists;
  final List<ReminderList> deletedLists;
  final ReminderList? selectedList;
  final void Function(ReminderList list) onDelete;
  final void Function(ReminderList list) onTapList;
  final void Function() onRestore;

  const ReminderListSection({
    super.key,
    required this.lists,
    required this.deletedLists,
    required this.onDelete,
    required this.onTapList,
    required this.selectedList,
    required this.onRestore,
  });

  IconData _getIconData(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _getColor(int colorValue) {
    return Color(colorValue);
  }

  void _editList(BuildContext context, ReminderList list) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditReminderListScreen(reminderList: list),
      ),
    );

    if (result == true) {
      onRestore(); // hoặc gọi hàm cập nhật UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Text(
            'Danh sách của tôi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              closeWhenTapped: true,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: lists.length + (deletedLists.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (deletedLists.isNotEmpty && index == lists.length) {
                    return ListTile(
                      leading: const Icon(Icons.delete, color: Colors.grey),
                      title: const Text('Đã xóa gần đây'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DeletedReminderListsScreen(),
                          ),
                        );
                        if (result == true) {
                          onRestore();
                        }
                      },
                    );
                  }

                  final list = lists[index];

                  return Slidable(
                    key: ValueKey('${list.key}-${list.name}-${list.icon}-${list.color}'),
                    direction: Axis.horizontal,
                    endActionPane: ActionPane(
                      extentRatio: 0.4,
                      motion: const DrawerMotion(),
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _editList(context, list),
                                    child: Container(
                                      color: Colors.blue,
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.edit,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final remindersBox =
                                          Hive.box<Reminder>('reminders');
                                      final deletedRemindersBox =
                                          Hive.box<Reminder>(
                                              'deletedReminders');
                                      final deletedListBox =
                                          Hive.box<ReminderList>(
                                              'deletedReminderLists');
                                      final listBox = Hive.box<ReminderList>(
                                          'reminderLists');

                                      final remindersInList = remindersBox
                                          .values
                                          .where((r) => r.listKey == list.key)
                                          .toList();

                                      bool confirmDelete = true;

                                      if (remindersInList.isNotEmpty) {
                                        confirmDelete = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                    'Xóa danh sách?'),
                                                content: Text(
                                                  'Danh sách "${list.name}" đang chứa lời nhắc. Bạn có chắc muốn xóa không?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, false),
                                                    child: const Text('Hủy'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, true),
                                                    child: const Text('Xóa',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;

                                        if (!confirmDelete) {
                                          return;
                                        }
                                      }

                                      // Di chuyển lời nhắc sang hộp đã xóa
                                      for (var reminder in remindersInList) {
                                        final newReminder = Reminder(
                                          title: reminder.title,
                                          note: reminder.note,
                                          dateTime: reminder.dateTime,
                                          isCompleted: reminder.isCompleted,
                                          listKey: null,
                                          priority: reminder.priority,
                                        );

                                        await deletedRemindersBox
                                            .add(newReminder);
                                        await reminder.delete();
                                      }

                                      // Di chuyển danh sách sang hộp đã xóa
                                      final deletedList = ReminderList(
                                        name: list.name,
                                        color: list.color,
                                        icon: list.icon,
                                      );
                                      deletedList.reminders = HiveList(
                                        deletedRemindersBox,
                                        objects: deletedRemindersBox.values
                                            .where((r) => r.listKey == null)
                                            .toList(),
                                      );

                                      await deletedListBox.add(deletedList);

                                      ReminderList? originalList;
                                      try {
                                        originalList = listBox.values
                                            .firstWhere(
                                                (l) => l.key == list.key);
                                      } catch (_) {
                                        originalList = null;
                                      }

                                      if (originalList != null) {
                                        await originalList.delete();
                                      }

                                      onDelete(list); // Cập nhật lại giao diện
                                    },
                                    child: Container(
                                      color: Colors.red,
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getIconData(list.icon),
                        color: _getColor(list.color),
                      ),
                      title: Text(list.name),
                      selected: selectedList?.key == list.key,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RemindersOfListScreen(list: list),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
