//Mai làm
//Sửa icon mũi tên
import 'package:flutter/material.dart';

class EarlyReminderSelector extends StatelessWidget {
  final String selectedLabel;
  final ValueChanged<String> onChanged;

  const EarlyReminderSelector({
    super.key,
    required this.selectedLabel,
    required this.onChanged,
  });

  final List<String> options = const [
    'Không có',
    'Trước 5 phút',
    'Trước 15 phút',
    'Trước 30 phút',
    'Trước 1 giờ',
    'Trước 2 giờ',
    'Trước 1 ngày',
    'Trước 2 ngày',
    'Trước 1 tuần',
    'Trước 1 tháng',
    'Tuỳ chỉnh',
  ];

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final label = options[index];
              final isSelected = selectedLabel == label;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : null,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onChanged(label);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedLabel != 'Không có';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lời nhắc sớm",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Icon(
              isActive ? Icons.notifications_active_outlined : Icons.notifications_outlined,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            title: Text(
              selectedLabel,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.keyboard_arrow_down_outlined),
            onTap: () => _showOptions(context),
          ),
        ),
      ],
    );
  }
}
