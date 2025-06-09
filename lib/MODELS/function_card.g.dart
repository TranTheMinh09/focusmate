// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FunctionCardAdapter extends TypeAdapter<FunctionCard> {
  @override
  final int typeId = 4;

  @override
  FunctionCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FunctionCard(
      title: fields[0] as String,
      visible: fields[1] as bool,
      iconCodePoint: fields[2] as int,
      iconFontFamily: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FunctionCard obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.visible)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.iconFontFamily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
