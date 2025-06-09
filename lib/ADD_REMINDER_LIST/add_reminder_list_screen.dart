import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../MODELS/reminder_list.dart';
import 'icon_label_data.dart';

class AddReminderListScreen extends StatefulWidget {
  const AddReminderListScreen({super.key});

  @override
  State<AddReminderListScreen> createState() => _AddReminderListScreenState();
}

class _AddReminderListScreenState extends State<AddReminderListScreen> {
  final TextEditingController _nameController = TextEditingController();
  late final Box<ReminderList> _reminderListBox;

  IconData _selectedIcon = Icons.list;
  Color _selectedColor = Colors.blue;

  bool get _isInputValid => _nameController.text.trim().isNotEmpty;

  bool get _hasChanges {
    return _nameController.text.trim().isNotEmpty ||
        _selectedColor != Colors.blue ||
        _selectedIcon != Icons.list;
  }

  @override
  void initState() {
    super.initState();
    _reminderListBox = Hive.box<ReminderList>('reminderLists');
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy thay đổi?'),
        content: const Text('Bạn có muốn hủy và bỏ các thay đổi không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  void _saveList() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final existingKey = _reminderListBox.keys.firstWhere(
      (key) => _reminderListBox.get(key)?.name == name,
      orElse: () => null,
    );

    if (existingKey != null) {
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Danh sách đã tồn tại'),
          content: const Text('Bạn có muốn thay thế danh sách hiện tại không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (shouldReplace != true) return;

      await _reminderListBox.put(
        existingKey,
        ReminderList(
          name: name,
          icon: _selectedIcon.codePoint,
          color: _selectedColor.value,
        ),
      );
    } else {
      await _reminderListBox.add(
        ReminderList(
          name: name,
          icon: _selectedIcon.codePoint,
          color: _selectedColor.value,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;

    const double iconSize = 60;
    const double spacing = 10;
    const double nameInputHeight = 170;
    const double colorPickerHeight = 100;
    const double paddingAndSpacing = 120;

    final double availableHeight =
        screenHeight - nameInputHeight - colorPickerHeight - paddingAndSpacing;
    final int iconsPerColumn =
        (availableHeight / (iconSize + spacing)).floor().clamp(1, 10);
    final bool shouldScroll = iconsPerColumn < 4;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách mới'),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _isInputValid ? _saveList : null,
              child: Text(
                'Xong',
                style: TextStyle(
                  color: _isInputValid ? Colors.blue : Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: isLandscape
              ? Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildNameInputSection(),
                      ),
                    ),
                    const VerticalDivider(width: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildColorPicker(),
                            const SizedBox(height: 20),
                            _buildIconPicker(iconsPerColumn),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : shouldScroll
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildNameInputSection(),
                          const SizedBox(height: 20),
                          _buildColorPicker(),
                          const SizedBox(height: 20),
                          _buildIconPicker(iconsPerColumn),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildNameInputSection(),
                        const SizedBox(height: 20),
                        _buildColorPicker(),
                        const SizedBox(height: 20),
                        _buildIconPicker(iconsPerColumn),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildNameInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Icon(_selectedIcon, size: 80, color: _selectedColor),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Tên danh sách',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: _nameController.text.isNotEmpty
                  ? const SizedBox(width: 40) // Để cân bằng với suffixIcon
                  : null,
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _nameController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxDecoration(),
      height: 70,
      alignment: Alignment.centerLeft,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ColorPickerDialog.colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final color = ColorPickerDialog.colors[index];
          final isSelected = _selectedColor == color;

          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.grey, width: 2)
                    : null,
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconPicker(int iconsPerColumn) {
    const double iconSize = 60;
    const double spacing = 10;
    const int iconsPerRow = 6;

    final List<IconData> icons = iconLabelMap.keys.toList();
    final int iconsPerPage = iconsPerColumn * iconsPerRow;
    final int pageCount = (icons.length / iconsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: _boxDecoration(),
      height:
          iconSize * iconsPerColumn + spacing * (iconsPerColumn - 1) + 4 + 16,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pageCount,
        itemBuilder: (context, pageIndex) {
          final start = pageIndex * iconsPerPage;
          final end = (start + iconsPerPage).clamp(0, icons.length);
          final pageIcons = icons.sublist(start, end);

          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(iconsPerColumn, (rowIndex) {
                return Row(
                  children: List.generate(iconsPerRow, (colIndex) {
                    final iconIndex = rowIndex * iconsPerRow + colIndex;
                    if (iconIndex >= pageIcons.length) {
                      return const SizedBox(width: iconSize);
                    }

                    final icon = pageIcons[iconIndex];
                    final isSelected = _selectedIcon == icon;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                          _nameController
                            ..text = iconLabelMap[icon] ?? 'Danh sách mới'
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _nameController.text.length),
                            );
                        });
                      },
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        margin: EdgeInsets.only(
                          right: colIndex < iconsPerRow - 1 ? spacing : 0,
                          bottom: rowIndex < iconsPerColumn - 1 ? spacing : 0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.withOpacity(0.1) : null,
                          border: isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 28),
                      ),
                    );
                  }),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4),
      ],
    );
  }
}

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  static final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.grey,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn màu'),
      content: Wrap(
        children: colors.map((color) {
          return GestureDetector(
            onTap: () => Navigator.pop(context, color),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
