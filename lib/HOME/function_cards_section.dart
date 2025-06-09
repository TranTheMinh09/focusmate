import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../MODELS/function_card.dart';

import '../HOME/1today_screen.dart';
import '../HOME/2all_reminders_screen.dart';
import '../HOME/3completed_reminders_screen.dart';
import '../HOME/4schedule_screen.dart';

class FunctionCardsSection extends StatefulWidget {
  final bool isEditing;
  final Function(List<FunctionCard>) onSaveCards;

  const FunctionCardsSection({
    super.key,
    required this.isEditing,
    required this.onSaveCards,
  });

  @override
  _FunctionCardsSectionState createState() => _FunctionCardsSectionState();
}

class _FunctionCardsSectionState extends State<FunctionCardsSection> {
  late Box<FunctionCard> box;
  List<FunctionCard> functionCards = [];

  @override
  void initState() {
    super.initState();
    _initBox();
  }

  Future<void> _initBox() async {
    box = await Hive.openBox<FunctionCard>('functionCards');
    if (box.isEmpty) {
      final defaultCards = [
        FunctionCard.withIcon(
            title: 'Hôm nay', icon: Icons.today, visible: true),
        FunctionCard.withIcon(
            title: 'Lịch dự kiến', icon: Icons.schedule, visible: true),
        FunctionCard.withIcon(title: 'Tất cả', icon: Icons.list, visible: true),
        FunctionCard.withIcon(
            title: 'Đã hoàn tất', icon: Icons.check_circle, visible: true),
      ];
      await box.addAll(defaultCards);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    setState(() {
      functionCards = box.values.toList();
    });
  }

  Future<void> _saveAll() async {
    await box.clear();
    await box.addAll(functionCards);
    widget.onSaveCards(functionCards);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: functionCards.length,
        onReorder: (oldIndex, newIndex) async {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = functionCards.removeAt(oldIndex);
          functionCards.insert(newIndex, item);
          await _saveAll();
          setState(() {});
        },
        itemBuilder: (_, index) {
          final card = functionCards[index];
          return ListTile(
            key: ValueKey(card.key),
            tileColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: GestureDetector(
              onTap: () async {
                card.visible = !card.visible;
                await card.save();
                setState(() {});
              },
              child: Icon(
                card.visible ? Icons.visibility : Icons.visibility_off,
                color: card.visible ? Colors.green : Colors.grey,
              ),
            ),
            title: Text(card.title),
            trailing: const Icon(Icons.menu, color: Colors.grey),
          );
        },
      );
    } else {
      final visibleCards = functionCards.where((c) => c.visible).toList();
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: visibleCards.length == 1
            ? _buildSingleCard(visibleCards.first)
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: visibleCards.length,
                itemBuilder: (_, index) =>
                    _buildFunctionCard(visibleCards[index]),
              ),
      );
    }
  }

  Widget _buildSingleCard(FunctionCard card) {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(child: _buildFunctionCard(card)),
        ],
      ),
    );
  }

  Widget _buildFunctionCard(FunctionCard card) {
    return GestureDetector(
      onTap: () => _navigateToCardPage(card),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(card.icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              AutoSizeText(
                card.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCardPage(FunctionCard card) {
    if (card.title == 'Hôm nay') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const TodayScreen()));
    } else if (card.title == 'Lịch dự kiến') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ScheduleScreen()));
    } else if (card.title == 'Tất cả') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AllRemindersScreen()));
    } else if (card.title == 'Đã hoàn tất') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CompletedRemindersScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chức năng chưa hỗ trợ: ${card.title}')),
      );
    }
  }
}
