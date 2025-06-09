//Tiêu đề và ghi chú

import 'package:flutter/material.dart';

class TitleAndNoteSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController noteController;

  const TitleAndNoteSection({
    super.key,
    required this.titleController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            minLines: isLandscape ? 3 : 1, // 👈 tự động giãn thêm khi ngang
            maxLines: isLandscape ? 6 : 5,
            decoration: InputDecoration(
              hintText: titleController.text.isEmpty ? 'Tiêu đề' : null,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),
          TextField(
            controller: noteController,
            minLines: isLandscape ? 5 : 3, // 👈 tự giãn khi ngang
            maxLines: isLandscape ? 12 : 10,
            decoration: const InputDecoration(
              hintText: 'Ghi chú',
              hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
