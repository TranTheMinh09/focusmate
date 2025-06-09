import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../MODELS/reminder_list.dart';
import '../../../MODELS/function_card.dart';
import 'function_cards_section.dart';
import 'reminder_list_section.dart';
import 'bottom_actions.dart';

import '../ADD_REMINDER_LIST/add_reminder_list_screen.dart';
import '../ADD_REMINDER/add_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<ReminderList> reminderListBox;
  late Box<ReminderList> deletedListBox;
  bool isEditingFunctions = false;
  List<FunctionCard> functionCards = [];

  ReminderList? selectedList;

  @override
  void initState() {
    super.initState();
    reminderListBox = Hive.box<ReminderList>('reminderLists');
    deletedListBox = Hive.box<ReminderList>('deletedReminderLists');
    _loadFunctionCards();
  }

  Future<void> _loadFunctionCards() async {
    final box = await Hive.openBox<FunctionCard>('functionCards');
    final cards = box.values.toList();

    // Nếu chưa có dữ liệu, khởi tạo mặc định
    if (cards.isEmpty) {
      functionCards = [
        FunctionCard.withIcon(
            title: 'Hôm nay', icon: Icons.today, visible: true),
        FunctionCard.withIcon(
            title: 'Lịch dự kiến', icon: Icons.schedule, visible: true),
        FunctionCard.withIcon(title: 'Tất cả', icon: Icons.list, visible: true),
        FunctionCard.withIcon(
            title: 'Đã hoàn tất', icon: Icons.check_circle, visible: true),
      ];
      await _saveFunctionCards();
    } else {
      functionCards = cards;
    }
    setState(() {});
  }

  Future<void> _saveFunctionCards() async {
    final box = await Hive.openBox<FunctionCard>('functionCards');
    await box.clear();
    for (int i = 0; i < functionCards.length; i++) {
      await box.put(i, functionCards[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = reminderListBox.values.toList();
    final deletedLists = deletedListBox.values.toList();

    return Scaffold(
      backgroundColor: Colors.white, // Đảm bảo nền trắng cho toàn bộ màn hình
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white, // Cố định màu AppBar
        elevation: 0.5, // Tạo đường phân cách nhẹ (hoặc dùng 0 nếu muốn phẳng)
        title: const Text('FocusMate', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          isEditingFunctions
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      isEditingFunctions = false;
                    });
                  },
                  child: const Text(
                    'Xong',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                )
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      setState(() {
                        isEditingFunctions = true;
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Sửa các thẻ'),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;

            return Container(
                color: Colors.white,
                child: isPortrait
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FunctionCardsSection(
                            isEditing: isEditingFunctions,
                            onSaveCards: (cards) {},
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ReminderListSection(
                              lists: lists,
                              deletedLists: deletedLists,
                              onDelete: (list) async {
                                setState(
                                    () {}); // chỉ cần gọi setState là đủ, vì box đã mở rồi
                              },
                              onTapList: (list) {
                                setState(() {
                                  selectedList = list;
                                });
                              },
                              selectedList: selectedList,
                              onRestore: () {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: FunctionCardsSection(
                                isEditing: isEditingFunctions,
                                onSaveCards: (cards) {},
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(
                            flex: 6,
                            child: ReminderListSection(
                              lists: lists,
                              deletedLists: deletedLists,
                              onDelete: (list) async {
                                setState(
                                    () {}); // chỉ cần gọi setState là đủ, vì box đã mở rồi
                              },
                              onTapList: (list) {
                                setState(() {
                                  selectedList = list;
                                });
                              },
                              selectedList: selectedList,
                              onRestore: () {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ));
          },
        ),
      ),

      bottomNavigationBar: BottomActions(
        selectedList: selectedList,
        hasAnyList: lists.isNotEmpty,
        onAddList: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddReminderListScreen(),
            ),
          );
          setState(() {}); // Cập nhật lại giao diện sau khi thêm danh sách
        },
        onAddReminder: (selectedList) async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddReminderScreen(selectedList: selectedList),
            ),
          );
          setState(() {}); // Cập nhật lại giao diện sau khi thêm
        },
      ),
    );
  }
}
