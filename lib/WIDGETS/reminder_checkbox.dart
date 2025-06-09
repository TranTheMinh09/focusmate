import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder.dart';
import '../HELPERS/repeat_utils.dart';
import '../main.dart';

int priorityWeight(Priority p) {
  switch (p) {
    case Priority.high:
      return 0;
    case Priority.medium:
      return 1;
    case Priority.low:
      return 2;
    default:
      return 3;
  }
}

class ReminderCheckbox extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback onReminderUpdated;

  const ReminderCheckbox({
    super.key,
    required this.reminder,
    required this.onReminderUpdated,
  });

  @override
  State<ReminderCheckbox> createState() => _ReminderCheckboxState();
}

class _ReminderCheckboxState extends State<ReminderCheckbox> {
  late bool _isCheckedTemp;
  static final List<Function> _taskQueue = [];
  static bool _isRunning = false;
  static final Set<dynamic> _pendingCompletionKeys =
      {}; // Store keys being processed
  late Box<Reminder> reminderBox;

  @override
  void initState() {
    super.initState();
    _isCheckedTemp = widget.reminder.isCompleted;
    reminderBox = Hive.box<Reminder>('reminders');
  }

  void _onChanged(bool? newValue) {
    if (newValue == null) return;

    setState(() {
      _isCheckedTemp = newValue;
    });

    _pendingCompletionKeys.add(widget.reminder.key); // track this reminder

    _taskQueue.add(() => _processReminder(newValue));

    if (!_isRunning) {
      _runQueue();
    }
  }

  Future<void> _runQueue() async {
    _isRunning = true;

    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeAt(0);
      await task();
      await Future.delayed(const Duration(seconds: 2));
    }

    _isRunning = false;
  }

  Future<void> _processReminder(bool newValue) async {
    await Future.delayed(const Duration(seconds: 1)); // ⏱ delay trước khi xử lý

    widget.reminder.isCompleted = newValue;
    await widget.reminder.save();

    _pendingCompletionKeys.remove(widget.reminder.key); // done processing

    if (newValue) {
      int baseId = priorityWeight(widget.reminder.priority) * 100000 +
          (widget.reminder.key as int);
      int repeatCount = widget.reminder.priority == Priority.medium
          ? 2
          : widget.reminder.priority == Priority.high
              ? 3
              : 1;

      for (int i = 0; i < repeatCount; i++) {
        await flutterLocalNotificationsPlugin.cancel(baseId + i);
      }

      await flutterLocalNotificationsPlugin.cancel(baseId + 999);
    } else if (widget.reminder.repeatOption != 'Không') {
      final nextTime = calculateNextOccurrence(widget.reminder);
      if (nextTime != null) {
        final newReminder = Reminder(
          title: widget.reminder.title,
          note: widget.reminder.note,
          dateTime: nextTime,
          priority: widget.reminder.priority,
          listKey: widget.reminder.listKey,
          isCompleted: false,
          repeatOption: widget.reminder.repeatOption,
          customRepeatFrequency: widget.reminder.customRepeatFrequency,
          customRepeatUnit: widget.reminder.customRepeatUnit,
          earlyReminder: widget.reminder.earlyReminder,
        );
        await reminderBox.add(newReminder);
      }
    }

    widget.onReminderUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _pendingCompletionKeys.contains(widget.reminder.key) ||
          _isCheckedTemp,
      onChanged: _onChanged,
      activeColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
