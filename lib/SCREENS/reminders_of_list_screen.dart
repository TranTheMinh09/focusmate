import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../MODELS/reminder.dart';
import '../MODELS/reminder_list.dart';
import '../WIDGETS/reminder_checkbox.dart';
import '../SCREENS/edit_reminder_screen.dart';
import '../SCREENS/reminder_detail_screen.dart';
import '../ADD_REMINDER/add_reminder_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RemindersOfListScreen extends StatefulWidget {
  final ReminderList list;

  const RemindersOfListScreen({super.key, required this.list});

  @override
  State<RemindersOfListScreen> createState() => _RemindersOfListScreenState();
}

class _RemindersOfListScreenState extends State<RemindersOfListScreen> {
  late Box<Reminder> reminderBox;

  @override
  void initState() {
    super.initState();
    reminderBox = Hive.box<Reminder>('reminders');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.list.name),
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: reminderBox.listenable(),
          builder: (context, Box<Reminder> box, _) {
            final reminders = box.values
                .where((r) => r.listKey == widget.list.key && !r.isCompleted)
                .toList()
              ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

            return Stack(
              children: [
                reminders.isEmpty
                    ? const Center(
                        child: Text(
                          "Chưa có lời nhắc nào.",
                          style: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.systemGrey2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemCount: reminders.length + 1,
                        itemBuilder: (context, index) {
                          if (index == reminders.length) {
                            return const SizedBox(
                                height:
                                    60); // phần đệm để cuộn được lời nhắc cuối
                          }
                          final reminder = reminders[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReminderDetailScreen(
                                      reminderId: reminder.key as int),
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
                                      extentRatio: 2 / 3,
                                      children: [
                                        CustomSlidableAction(
                                          onPressed: (_) async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    EditReminderScreen(
                                                        reminder: reminder),
                                              ),
                                            );
                                            setState(() {});
                                          },
                                          backgroundColor: Colors.blue.shade100,
                                          foregroundColor: Colors.blue,
                                          child: SizedBox(
                                            width: itemWidth,
                                            height: itemHeight,
                                            child: const Center(
                                              child: Icon(Icons.edit,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                        CustomSlidableAction(
                                          onPressed: (_) async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title:
                                                    const Text("Xác nhận xoá"),
                                                content: const Text(
                                                    "Bạn có chắc muốn xoá lời nhắc này không?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child: const Text("Huỷ")),
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: const Text("Xoá",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red))),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await reminder.delete();
                                              setState(() {});
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
                                              child: Icon(Icons.delete,
                                                  color: Colors.red),
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
                                            onReminderUpdated: () =>
                                                setState(() {}),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.notifications_active,
                                              color: CupertinoColors.systemBlue,
                                              size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reminder.title,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        CupertinoColors.label,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat(
                                                          'dd/MM/yyyy – HH:mm')
                                                      .format(
                                                          reminder.dateTime),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: CupertinoColors
                                                        .systemGrey,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                                if (reminder.priority !=
                                                    Priority.none) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    reminder.priority ==
                                                            Priority.high
                                                        ? 'Khẩn cấp'
                                                        : reminder.priority ==
                                                                Priority.medium
                                                            ? 'Quan trọng'
                                                            : 'Thông thường',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: reminder
                                                                  .priority ==
                                                              Priority.high
                                                          ? CupertinoColors
                                                              .systemRed
                                                          : reminder.priority ==
                                                                  Priority
                                                                      .medium
                                                              ? CupertinoColors
                                                                  .systemOrange
                                                              : CupertinoColors
                                                                  .systemGreen,
                                                      decoration:
                                                          TextDecoration.none,
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
                        },
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddReminderScreen(selectedList: widget.list),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add,
                                    size: 18, color: Color(0xFF007AFF)),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Lời nhắc mới',
                                style: TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
