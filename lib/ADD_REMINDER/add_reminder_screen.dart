//Sửa lại font chữ
//Mức ưu tiên giống với lời nhắc sớm,lặp lại
//Kiểm tra chức năng lặp lại
//Phần ngày giờ icon thẳng hàng vơi chữ ngày giờ
// Sửa icon dấu mũi tên của lời nhắc sớm và lặp lại

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder.dart';
import '../MODELS/reminder_list.dart';
import '../HELPERS/notification_helper.dart';
import '../HELPERS/early_reminder_utils.dart';
import 'title_and_note_section.dart';
import 'detail_section.dart';
import 'list_selection_tile.dart';

class AddReminderScreen extends StatefulWidget {
  final ReminderList? selectedList;

  const AddReminderScreen({super.key, this.selectedList});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  ReminderList? selectedList;
  bool showDetailBox = false;
  bool hasDate = false;
  bool hasTime = false;
  Priority priorityLevel = Priority.none;
  int _customEarlyValue = 1;
  String _customEarlyUnit = 'phút';
  String _earlyReminder = 'Không có';
  final List<String> _earlyUnits = ['phút', 'giờ', 'ngày', 'tuần', 'tháng'];

  //
  String _repeatLabel = 'Không'; // hoặc 'Không lặp lại'
  int _customRepeatFrequency = 1;
  String _customRepeatUnit = 'ngày';
  final List<String> _repeatUnits = ['ngày', 'tuần', 'tháng', 'năm'];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool get isSaveEnabled =>
      _titleController.text.trim().isNotEmpty &&
      selectedList != null &&
      hasDate &&
      selectedDate != null &&
      hasTime &&
      selectedTime != null &&
      isReminderTimeValid;

  bool get hasChanges =>
      _titleController.text.isNotEmpty ||
      _noteController.text.isNotEmpty ||
      hasDate ||
      hasTime ||
      priorityLevel != Priority.none ||
      selectedList != null;

  bool get isReminderTimeValid {
    if (!hasDate || selectedDate == null) return true;
    final now = DateTime.now();
    final reminderDateTime = hasTime && selectedTime != null
        ? DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day,
            selectedTime!.hour, selectedTime!.minute)
        : DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    return reminderDateTime.isAfter(now);
  }

  @override
  void initState() {
    super.initState();
    selectedList = widget.selectedList;
    _earlyReminder = 'Không có';
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    } else {
      setState(() => hasDate = false);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    } else {
      setState(() => hasTime = false);
    }
  }

  void _handleCancel() {
    if (hasChanges) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Huỷ thay đổi?'),
          content: const Text('Bạn có chắc muốn huỷ bỏ thay đổi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục chỉnh sửa',
                  style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Huỷ bỏ', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
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

    // 🆕 Lặp lại:
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

      // 🆕 Lặp lại:
      _repeatLabel = newRepeatLabel ?? _repeatLabel;
      _customRepeatFrequency = newRepeatFrequency ?? _customRepeatFrequency;
      _customRepeatUnit = newRepeatUnit ?? _customRepeatUnit;
    });
  }

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

  String getPriorityLabelText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return "Thông thường";
      case Priority.medium:
        return "Quan trọng";
      case Priority.high:
        return "Khẩn cấp";
      default:
        return "";
    }
  }

  String getExclamationIcons(Priority priority) {
    switch (priority) {
      case Priority.low:
        return " ❗";
      case Priority.medium:
        return " ❗❗";
      case Priority.high:
        return " ❗❗❗";
      default:
        return "";
    }
  }

  Color getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveReminder() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || selectedList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề và chọn danh sách'),
        ),
      );
      return;
    }

    DateTime? finalDateTime;
    if (hasDate && selectedDate != null) {
      finalDateTime = hasTime && selectedTime != null
          ? DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
            )
          : DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
            );
    }
    finalDateTime ??= DateTime.now();

    DateTime? earlyReminderTime = calculateEarlyReminderTime(
      baseTime: finalDateTime,
      earlyReminderLabel: _earlyReminder,
      customValue: _customEarlyValue,
      customUnit: _customEarlyUnit,
    );

    if (_earlyReminder != 'Không có' && earlyReminderTime == null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Không có Lời nhắc sớm"),
          content: const Text(
              "Sẽ không có thông báo sớm nào được gửi vì thời gian này đã trôi qua."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    final reminder = Reminder(
      title: title,
      note: _noteController.text.trim(),
      dateTime: finalDateTime,
      priority: priorityLevel,
      listKey: selectedList!.key,
      isCompleted: false,
      earlyReminder: earlyReminderTime != null
          ? finalDateTime.difference(earlyReminderTime)
          : null,
      repeatOption: _repeatLabel,
      customRepeatFrequency:
          _repeatLabel == 'Tùy chỉnh' ? _customRepeatFrequency : null,
      customRepeatUnit: _repeatLabel == 'Tùy chỉnh' ? _customRepeatUnit : null,
    );

    // ==== Mở Hive box và lưu reminder ====
    final remindersBox = await Hive.openBox<Reminder>('reminders');
    final reminderKey = await remindersBox.add(reminder);
    reminder.id = reminderKey;
    await reminder.save();

    // ==== Gửi thông báo chính ====
    int baseId = priorityWeight(priorityLevel) * 100000 + reminderKey;

    // Định dạng thời gian
    final formattedTime = '${finalDateTime.day.toString().padLeft(2, '0')}/'
        '${finalDateTime.month.toString().padLeft(2, '0')}/'
        '${finalDateTime.year}, '
        '${finalDateTime.hour.toString().padLeft(2, '0')}:'
        '${finalDateTime.minute.toString().padLeft(2, '0')}';

    final priorityTitle =
        '${getPriorityLabelText(priorityLevel)}${getExclamationIcons(priorityLevel)}';

    final mainBody = '[Nhắc nhở] $title\n$formattedTime';

    Duration interval;
    int repeatCount;

    switch (priorityLevel) {
      case Priority.high:
        interval = const Duration(hours: 1);
        repeatCount = 3; // Số lần lặp lại tối đa
        break;
      case Priority.medium:
        interval = const Duration(hours: 12);
        repeatCount = 2; // Số lần lặp lại tối đa
        break;
      case Priority.low:
        interval = const Duration(hours: 24);
        repeatCount = 1; // Số lần lặp lại tối đa
        break;
      default:
        interval =
            const Duration(days: 3); // Không lặp lại nếu không có ưu tiên
        repeatCount = 1; // Không lặp lại nếu không có ưu tiên
        break;
    }

    // Gửi thông báo lặp lại cho đến khi lời nhắc hoàn thành
// Gửi thông báo lặp lại cho đến khi lời nhắc hoàn thành
    if (interval != Duration.zero) {
      await scheduleRepeatingNotifications(
        baseId: baseId,
        title: priorityTitle,
        body: mainBody,
        startTime: finalDateTime,
        interval: interval,
        repeatCount:
            repeatCount, // Sử dụng repeatCount tính toán từ mức độ ưu tiên
        payload: reminderKey.toString(),
      );
    }
    if (earlyReminderTime != null) {
      final earlyBody = '[Nhắc nhở sớm] $title\n$formattedTime';

      await scheduleNotification(
        id: baseId + 999, // Hoặc baseId + repeatCount nếu muốn liên tục
        title: priorityTitle,
        body: earlyBody,
        scheduledDate: earlyReminderTime,
        vibrate: true,
        payload: reminderKey.toString(), // ✅ thêm dòng này
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: isLandscape
                ? SizedBox.expand(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bên trái: Tiêu đề & Ghi chú
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 8),
                            child: SingleChildScrollView(
                              child: TitleAndNoteSection(
                                titleController: _titleController,
                                noteController: _noteController,
                              ),
                            ),
                          ),
                        ),

                        // Thanh ngăn cách DẠNG DỌC TỰ GIÃN
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),

                        // Bên phải: Chi tiết + Danh sách
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 8),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                    isReminderTimeValid: isReminderTimeValid,
                                    onUpdate: _onDetailUpdate,
                                    pickDate: _pickDate,
                                    pickTime: _pickTime,
                                    showDetailBox:
                                        showDetailBox, // ✅ cho phép bật/tắt
                                    toggleDetailBox: () => setState(() =>
                                        showDetailBox =
                                            !showDetailBox), // luôn mở trong landscape

                                    // 🆕 Thêm:
                                    repeatLabel: _repeatLabel,
                                    customRepeatFrequency:
                                        _customRepeatFrequency,
                                    customRepeatUnit: _customRepeatUnit,
                                    repeatUnits: _repeatUnits,
                                  ),
                                  const SizedBox(height: 16),
                                  ListSelectionTile(
                                    selectedList: selectedList,
                                    onListSelected: (list) =>
                                        setState(() => selectedList = list),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
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
                          isReminderTimeValid: isReminderTimeValid,
                          onUpdate: _onDetailUpdate,
                          pickDate: _pickDate,
                          pickTime: _pickTime,
                          showDetailBox: showDetailBox,
                          toggleDetailBox: () =>
                              setState(() => showDetailBox = !showDetailBox),
                          // 🆕 Thêm:
                          repeatLabel: _repeatLabel,
                          customRepeatFrequency: _customRepeatFrequency,
                          customRepeatUnit: _customRepeatUnit,
                          repeatUnits: _repeatUnits,
                        ),
                        const SizedBox(height: 16),
                        ListSelectionTile(
                          selectedList: selectedList,
                          onListSelected: (list) =>
                              setState(() => selectedList = list),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      shadowColor: Colors.transparent, // <- ngăn màu đổ bóng khi cuộn
      surfaceTintColor: Colors.transparent, // <- chống đổi màu trên Android 12+
      leadingWidth: 80,
      leading: TextButton(
        onPressed: _handleCancel,
        child: const Text("Huỷ", style: TextStyle(color: Colors.blue)),
      ),
      title: const Text("Lời nhắc mới", style: TextStyle(color: Colors.black)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      actions: [
        TextButton(
          onPressed: isSaveEnabled ? _saveReminder : null,
          child: Text(
            "Thêm",
            style: TextStyle(
              color: isSaveEnabled ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
