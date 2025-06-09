import 'package:flutter/material.dart';
import '../MODELS/reminder_list.dart';
import 'select_list_screen.dart';

class ListSelectionTile extends StatelessWidget {
  final ReminderList? selectedList;
  final void Function(ReminderList) onListSelected;

  const ListSelectionTile({
    super.key,
    required this.selectedList,
    required this.onListSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedList != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final selected = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SelectListScreen()),
          );
          if (selected != null && selected is ReminderList) {
            onListSelected(selected);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              isSelected
                  ? CircleAvatar(
                      backgroundColor: Color(selectedList!.color),
                      child: Icon(
                        IconData(selectedList!.icon,
                            fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.list_alt_outlined, color: Colors.grey),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isSelected ? selectedList!.name : 'Danh sách',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.black : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
