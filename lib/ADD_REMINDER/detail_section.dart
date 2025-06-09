import 'package:flutter/material.dart';
import '../MODELS/reminder.dart';
import '../HELPERS/priority_utils.dart';
import 'early_reminder_selector.dart';
import 'repeat_selector.dart';
import 'package:flutter/cupertino.dart';

class DetailSection extends StatelessWidget {
  final bool showDetailBox;
  final bool hasDate;
  final bool hasTime;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Priority priorityLevel;
  final String earlyReminder;
  final int customEarlyValue;
  final String customEarlyUnit;
  final List<String> earlyUnits;
  final bool isReminderTimeValid;

  final String repeatLabel;
  final int customRepeatFrequency;
  final String customRepeatUnit;
  final List<String> repeatUnits;

  final Future<void> Function() pickDate;
  final Future<void> Function() pickTime;

  final VoidCallback toggleDetailBox;

  final void Function({
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
  }) onUpdate;

  const DetailSection({
    super.key,
    required this.showDetailBox,
    required this.hasDate,
    required this.hasTime,
    required this.selectedDate,
    required this.selectedTime,
    required this.priorityLevel,
    required this.earlyReminder,
    required this.customEarlyValue,
    required this.customEarlyUnit,
    required this.earlyUnits,
    required this.pickDate,
    required this.pickTime,
    required this.onUpdate,
    required this.isReminderTimeValid,
    required this.toggleDetailBox,
    required this.repeatLabel,
    required this.customRepeatFrequency,
    required this.customRepeatUnit,
    required this.repeatUnits,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: const Text("Chi tiết",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              trailing: Icon(
                showDetailBox
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey.shade700,
              ),
              onTap: toggleDetailBox,
            ),
          ),
          if (showDetailBox)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateToggle(),
                  if (hasDate && selectedDate != null) _buildSelectedDate(),
                  _buildTimeToggle(context),
                  if (hasTime && selectedTime != null)
                    _buildSelectedTime(context),
                  const SizedBox(height: 12),
                  _buildPriorityDropdown(),
                  const SizedBox(height: 12),
                  EarlyReminderSelector(
                    selectedLabel: earlyReminder,
                    onChanged: (val) => onUpdate(newEarlyReminder: val),
                  ),
                  if (earlyReminder == 'Tuỳ chỉnh')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildCustomDropdown(
                        customEarlyValue,
                        customEarlyUnit,
                        earlyUnits,
                        isEarly: true,
                      ),
                    ),
                  const SizedBox(height: 12),
                  RepeatSelector(
                    selectedLabel: repeatLabel,
                    onChanged: (val) => onUpdate(newRepeatLabel: val),
                  ),
                  if (repeatLabel == 'Tùy chỉnh')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildCustomDropdown(
                          customRepeatFrequency, customRepeatUnit, repeatUnits,
                          isEarly: false),
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildCustomDropdown(int value, String unit, List<String> unitOptions,
      {required bool isEarly}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 2),
                    blurRadius: 6),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                onChanged: (val) {
                  if (val != null) {
                    isEarly
                        ? onUpdate(newCustomValue: val)
                        : onUpdate(newRepeatFrequency: val);
                  }
                },
                menuMaxHeight: 275,
                items: List.generate(200, (i) => i + 1).map((val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text(val.toString(),
                        style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 2),
                    blurRadius: 6),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: unit,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                onChanged: (val) {
                  if (val != null) {
                    isEarly
                        ? onUpdate(newCustomUnit: val)
                        : onUpdate(newRepeatUnit: val);
                  }
                },
                items: unitOptions.map((u) {
                  return DropdownMenuItem<String>(
                    value: u,
                    child: Text(u, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Ngày", style: TextStyle(fontSize: 16)),
          Switch.adaptive(
            value: hasDate,
            activeColor: Colors.white,
            activeTrackColor: Colors.green.shade300,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (val) {
              onUpdate(newHasDate: val);
              if (val) {
                pickDate();
              } else {
                onUpdate(
                  newSelectedDate: null,
                  newHasTime: false,
                  newSelectedTime: null,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDate() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          const Icon(CupertinoIcons.calendar, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isReminderTimeValid ? Colors.black87 : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeToggle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Thời gian"),
        Switch(
          value: hasTime,
          activeColor: Colors.white,
          activeTrackColor: Colors.green.shade300,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: (val) {
            if (val) {
              // Nếu chưa có ngày → chọn hôm nay luôn
              if (!hasDate || selectedDate == null) {
                onUpdate(
                  newHasDate: true,
                  newSelectedDate: DateTime.now(),
                );
              }

              onUpdate(newHasTime: true);
              showTimePickerDialog(context); // Gọi hàm showTimePicker
            } else {
              onUpdate(
                newHasTime: false,
                newSelectedTime: null,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectedTime(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          const Icon(CupertinoIcons.time, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            selectedTime!.format(context),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isReminderTimeValid ? Colors.black87 : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mức ưu tiên",
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            height: 55,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final currentFocus = FocusScope.of(context);

                // 🧹 Gỡ focus nếu có
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  currentFocus.focusedChild!.unfocus();
                }

                // 🕒 Delay dài hơn 200ms để đảm bảo Flutter cập nhật lại focus state
                await Future.delayed(const Duration(milliseconds: 250));

                // 👉 Tiếp tục mở menu
                final RenderBox box = context.findRenderObject() as RenderBox;
                final Offset position = box.localToGlobal(Offset.zero);

                final selected = await showMenu<Priority>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx + box.size.width,
                    position.dy + box.size.height,
                    position.dx,
                    0,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  items: Priority.values.map((p) {
                    return PopupMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          _getPriorityIcon(p),
                          const SizedBox(width: 8),
                          Text(getPriorityLabel(p),
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                );

                if (selected != null) {
                  onUpdate(newPriority: selected);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getPriorityLabel(priorityLevel),
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87)),
                    Row(
                      children: [
                        _getPriorityIcon(priorityLevel),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.black54),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Icon _getPriorityIcon(Priority p) {
    switch (p) {
      case Priority.high:
        return const Icon(Icons.warning_amber_rounded,
            color: Colors.redAccent, size: 20);
      case Priority.medium:
        return const Icon(Icons.error_outline, color: Colors.orange, size: 20);
      case Priority.low:
        return const Icon(Icons.check_circle_outline,
            color: Colors.green, size: 20);
      case Priority.none:
      default:
        return const Icon(Icons.remove_circle_outline,
            color: Colors.grey, size: 20);
    }
  }

  Widget _buildCustomEarlyReminder() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<int>(
              value: customEarlyValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: List.generate(200, (i) => i + 1).map((val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text(val.toString()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onUpdate(newCustomValue: val);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: customEarlyUnit,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: earlyUnits.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onUpdate(newCustomUnit: val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Thay thế showHourMinutePicker bằng showTimePicker
  void showTimePickerDialog(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onUpdate(newSelectedTime: pickedTime);
    } else {
      onUpdate(newHasTime: false, newSelectedTime: null);
    }
  }
}
