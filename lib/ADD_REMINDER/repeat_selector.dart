//Mai làm
//Sửa icon mũi tên
import 'package:flutter/material.dart';

class RepeatSelector extends StatelessWidget {
  final String selectedLabel;
  final ValueChanged<String> onChanged;

  const RepeatSelector({
    super.key,
    required this.selectedLabel,
    required this.onChanged,
  });

  final List<String> options = const [
    'Không',
    'Hàng ngày',
    'Ngày thường',
    'Cuối tuần',
    'Hàng tuần',
    'Hai tuần một lần',
    'Hàng tháng',
    'Mỗi 3 tháng',
    'Mỗi 6 tháng',
    'Hàng năm',
    'Tùy chỉnh',
  ];

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ListView.builder(
          itemCount: options.length,
          itemBuilder: (context, index) {
            final label = options[index];
            final isSelected = label == selectedLabel;
            return ListTile(
              title: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : null,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                Navigator.pop(context);
                onChanged(label);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedLabel != 'Không';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lặp lại", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
              isActive ? Icons.repeat_on : Icons.repeat,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            title: Text(selectedLabel, style: const TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.keyboard_arrow_down_outlined),
            onTap: () => _showOptions(context),
          ),
        ),
      ],
    );
  }
}
