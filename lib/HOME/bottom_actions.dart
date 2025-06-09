import 'package:flutter/material.dart';
import '../../../../MODELS/reminder_list.dart';

class BottomActions extends StatelessWidget {
  final ReminderList? selectedList;
  final VoidCallback onAddList;
  final void Function(ReminderList? selectedList) onAddReminder;
  final bool hasAnyList;

  const BottomActions({
    super.key,
    required this.selectedList,
    required this.onAddList,
    required this.onAddReminder,
    required this.hasAnyList,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: hasAnyList
                  ? () => onAddReminder(selectedList)
                  : null, // ✅ chỉ bật khi có danh sách
              icon: const Icon(Icons.add),
              label: const Text('Lời nhắc mới'),
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: hasAnyList
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400, // ✅ đổi màu khi không có danh sách
                foregroundColor: hasAnyList
                    ? Colors.white
                    : Colors.black45, // ✅ màu chữ/icon
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: onAddList,
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Tạo danh sách mới',
          ),
        ],
      ),
    );
  }
}
