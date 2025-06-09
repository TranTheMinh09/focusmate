// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderListAdapter extends TypeAdapter<ReminderList> {
  @override
  final int typeId = 2;

  @override
  ReminderList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderList(
      name: fields[0] as String,
      icon: fields[2] as int,
      color: fields[3] as int,
      reminders: (fields[1] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, ReminderList obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.reminders)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
