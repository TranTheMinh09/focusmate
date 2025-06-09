import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'function_card.g.dart';

@HiveType(typeId: 4)
class FunctionCard extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool visible;

  @HiveField(2)
  int iconCodePoint;

  @HiveField(3)
  String iconFontFamily;

  // 🧱 Constructor Hive cần dùng
  FunctionCard({
    required this.title,
    required this.visible,
    required this.iconCodePoint,
    required this.iconFontFamily,
  });

  // 🎯 Constructor tiện lợi khi tạo từ IconData
  FunctionCard.withIcon({
    required this.title,
    required this.visible,
    required IconData icon,
  })  : iconCodePoint = icon.codePoint,
        iconFontFamily = icon.fontFamily ?? 'MaterialIcons';

  // 🔁 Trả lại IconData để dùng trong UI
  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);
}
