import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder.dart';
import '../MODELS/reminder_list.dart';
import '../HELPERS/early_reminder_utils.dart';
import '../ADD_REMINDER/title_and_note_section.dart';
import '../ADD_REMINDER/detail_section.dart';
import '../ADD_REMINDER/list_selection_tile.dart';
import '../HELPERS/notification_helper.dart' as notify_helper;

class EditReminderScreen extends StatefulWidget {
  final Reminder reminder;

  const EditReminderScreen({super.key, required this.reminder});

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  ReminderList? selectedList;
  bool showDetailBox = false;
  bool hasDate = false;
  bool hasTime = false;
  Priority priorityLevel = Priority.none;
  int _customEarlyValue = 1;
  String _customEarlyUnit = 'phút';
  String _earlyReminder = 'Không có';
  final List<String> _earlyUnits = ['phút', 'giờ', 'ngày', 'tuần', 'tháng'];

  String _repeatLabel = 'Không';
  int _customRepeatFrequency = 1;
  String _customRepeatUnit = 'ngày';
  final List<String> _repeatUnits = ['ngày', 'tuần', 'tháng', 'năm'];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Reminder get reminder => widget.reminder;

  bool get isSaveEnabled =>
      _titleController.text.trim().isNotEmpty && selectedList != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: reminder.title);
    _noteController = TextEditingController(text: reminder.note);

    final listBox = Hive.box<ReminderList>('reminderLists');
    for (var list in listBox.values) {
      if (list.key == reminder.listKey) {
        selectedList = list;
        break;
      }
    }

    hasDate = true;
    hasTime = true;
    selectedDate = reminder.dateTime;
    selectedTime = TimeOfDay.fromDateTime(reminder.dateTime);

    priorityLevel = reminder.priority;

    if (reminder.earlyReminder != null) {
      _earlyReminder = 'Tùy chỉnh';
      final minutes = reminder.earlyReminder!.inMinutes;
      if (minutes % 60 == 0) {
        _customEarlyUnit = 'giờ';
        _customEarlyValue = minutes ~/ 60;
      } else {
        _customEarlyUnit = 'phút';
        _customEarlyValue = minutes;
      }
    } else {
      _earlyReminder = 'Không có';
    }

    _repeatLabel = reminder.repeatOption;
    _customRepeatFrequency = reminder.customRepeatFrequency ?? 1;
    _customRepeatUnit = reminder.customRepeatUnit ?? 'ngày';
  }

  void _onDetailUpdate({
    bool? newHasDate,
    bool? newHasTime,
    DateTime? newSelectedDate,
    TimeOfDay? newSelectedTime,
    Priority? newPriority,
    String? newEarlyReminder,
    int? newCustomValue,
    String? newCustomUnit,
    String? newRepeatLabel,
    int? newRepeatFrequency,
    String? newRepeatUnit,
  }) {
    setState(() {
      hasDate = newHasDate ?? hasDate;
      hasTime = newHasTime ?? hasTime;
      selectedDate = newSelectedDate ?? selectedDate;
      selectedTime = newSelectedTime ?? selectedTime;
      priorityLevel = newPriority ?? priorityLevel;
      _earlyReminder = newEarlyReminder ?? _earlyReminder;
      _customEarlyValue = newCustomValue ?? _customEarlyValue;
      _customEarlyUnit = newCustomUnit ?? _customEarlyUnit;
      _repeatLabel = newRepeatLabel ?? _repeatLabel;
      _customRepeatFrequency = newRepeatFrequency ?? _customRepeatFrequency;
      _customRepeatUnit = newRepeatUnit ?? _customRepeatUnit;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _saveReminder() async {
    reminder.title = _titleController.text.trim();
    reminder.note = _noteController.text.trim();
    reminder.priority = priorityLevel;
    reminder.repeatOption = _repeatLabel;
    reminder.customRepeatFrequency =
        _repeatLabel == 'Tùy chỉnh' ? _customRepeatFrequency : null;
    reminder.customRepeatUnit =
        _repeatLabel == 'Tùy chỉnh' ? _customRepeatUnit : null;
    reminder.listKey = selectedList!.key;

    if (hasDate && selectedDate != null) {
      reminder.dateTime = hasTime && selectedTime != null
          ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day,
              selectedTime!.hour, selectedTime!.minute)
          : DateTime(
              selectedDate!.year, selectedDate!.month, selectedDate!.day);
    }

    if (_earlyReminder == 'Không có') {
      reminder.earlyReminder = null;
    } else {
      final early = calculateEarlyReminderTime(
        baseTime: reminder.dateTime,
        earlyReminderLabel: _earlyReminder,
        customValue: _customEarlyValue,
        customUnit: _customEarlyUnit,
      );
      if (early != null) {
        reminder.earlyReminder = reminder.dateTime.difference(early);
      }
    }

    await reminder.save();

// ❌ Huỷ thông báo cũ
    await notify_helper.flutterLocalNotificationsPlugin.cancel(reminder.key);
    // ❌ Huỷ thông báo nhắc sớm cũ nếu có
    await notify_helper.flutterLocalNotificationsPlugin
        .cancel(reminder.key.hashCode + 999);

// ✅ Gửi lại thông báo mới
    await notify_helper.scheduleNotification(
      id: reminder.key.hashCode,
      title: reminder.title,
      body: reminder.note ?? '',
      scheduledDate: reminder.dateTime,
      payload: reminder.key.toString(),
    );

// ✅ Gửi lại nhắc sớm nếu có
    if (reminder.earlyReminder != null) {
      final earlyTime = reminder.dateTime.subtract(reminder.earlyReminder!);
      await notify_helper.scheduleNotification(
        id: reminder.key.hashCode + 999,
        title: "[Nhắc sớm] ${reminder.title}",
        body: reminder.note ?? '',
        scheduledDate: earlyTime,
        payload: reminder.key.toString(),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: _handleCancel,
          child: const Text("Huỷ", style: TextStyle(color: Colors.blue)),
        ),
        title: const Text("Chỉnh sửa", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: isSaveEnabled ? _saveReminder : null,
            child: Text(
              "Lưu",
              style: TextStyle(
                color: isSaveEnabled ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleAndNoteSection(
                titleController: _titleController,
                noteController: _noteController,
              ),
              const SizedBox(height: 16),
              DetailSection(
                hasDate: hasDate,
                hasTime: hasTime,
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                priorityLevel: priorityLevel,
                earlyReminder: _earlyReminder,
                customEarlyUnit: _customEarlyUnit,
                customEarlyValue: _customEarlyValue,
                earlyUnits: _earlyUnits,
                isReminderTimeValid: true,
                onUpdate: _onDetailUpdate,
                pickDate: _pickDate,
                pickTime: _pickTime,
                showDetailBox: showDetailBox,
                toggleDetailBox: () =>
                    setState(() => showDetailBox = !showDetailBox),
                repeatLabel: _repeatLabel,
                customRepeatFrequency: _customRepeatFrequency,
                customRepeatUnit: _customRepeatUnit,
                repeatUnits: _repeatUnits,
              ),
              const SizedBox(height: 16),
              ListSelectionTile(
                selectedList: selectedList,
                onListSelected: (list) => setState(() => selectedList = list),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
