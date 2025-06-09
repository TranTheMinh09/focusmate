import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../MODELS/reminder_list.dart';

class SelectListScreen extends StatefulWidget {
  const SelectListScreen({super.key});

  @override
  State<SelectListScreen> createState() => _SelectListScreenState();
}

class _SelectListScreenState extends State<SelectListScreen> {
  String searchQuery = "";
  bool sortAscending = true;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSortOrder() {
    setState(() {
      sortAscending = !sortAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn danh sách"),
        actions: [
          IconButton(
            onPressed: _toggleSortOrder,
            tooltip: sortAscending ? 'Sắp xếp A-Z' : 'Sắp xếp Z-A',
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort_by_alpha),
                Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm danh sách...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<ReminderList>('reminderLists').listenable(),
              builder: (context, Box<ReminderList> box, _) {
                final filtered = box.values
                    .where(
                        (item) => item.name.toLowerCase().contains(searchQuery))
                    .toList()
                  ..sort((a, b) => sortAscending
                      ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
                      : b.name.toLowerCase().compareTo(a.name.toLowerCase()));

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text("Không tìm thấy danh sách nào"));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final reminderList = filtered[index];
                    final name = reminderList.name;
                    final matchIndex = name.toLowerCase().indexOf(searchQuery);

                    return ListTile(
                      leading: Icon(
                        IconData(reminderList.icon,
                            fontFamily: 'MaterialIcons'),
                        color: Color(reminderList.color),
                      ),
                      title: matchIndex != -1 && searchQuery.isNotEmpty
                          ? RichText(
                              text: TextSpan(
                                text: name.substring(0, matchIndex),
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: name.substring(matchIndex,
                                        matchIndex + searchQuery.length),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: name.substring(
                                        matchIndex + searchQuery.length),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            )
                          : Text(name),
                      onTap: () {
                        Navigator.pop(context, reminderList);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
