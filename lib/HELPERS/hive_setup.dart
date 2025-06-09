import 'package:hive_flutter/hive_flutter.dart';
import '../MODELS/reminder.dart';
import '../MODELS/reminder_list.dart';
import '../MODELS/function_card.dart';

Future<void> setupHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(ReminderListAdapter());
  Hive.registerAdapter(FunctionCardAdapter());

  final reminderBox = await Hive.openBox<Reminder>('reminders');
  final deletedRemindersBox = await Hive.openBox<Reminder>('deletedReminders');
  final reminderListBox = await Hive.openBox<ReminderList>('reminderLists');
  final deletedListBox =await Hive.openBox<ReminderList>('deletedReminderLists');

  await Hive.openBox<FunctionCard>('functionCards');

  for (var list in reminderListBox.values) {
    if (list.reminders == null || list.reminders is! HiveList<Reminder>) {
      list.reminders = HiveList(reminderBox);
      await list.save();
    }
  }

  for (var list in deletedListBox.values) {
    if (list.reminders == null || list.reminders is! HiveList<Reminder>) {
      list.reminders = HiveList(deletedRemindersBox);
      await list.save();
    }
  }
}
