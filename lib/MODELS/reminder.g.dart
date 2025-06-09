// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 0;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as int?,
      title: fields[1] as String,
      note: fields[2] as String,
      dateTime: fields[3] as DateTime,
      priority: fields[4] as Priority,
      isCompleted: fields[5] as bool,
      listKey: fields[6] as int?,
      repeatOption: fields[8] as String,
      customRepeatFrequency: fields[9] as int?,
      customRepeatUnit: fields[10] as String?,
    )..earlyReminderMillis = fields[7] as int?;
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.listKey)
      ..writeByte(7)
      ..write(obj.earlyReminderMillis)
      ..writeByte(8)
      ..write(obj.repeatOption)
      ..writeByte(9)
      ..write(obj.customRepeatFrequency)
      ..writeByte(10)
      ..write(obj.customRepeatUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 1;

  @override
  Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Priority.none;
      case 1:
        return Priority.low;
      case 2:
        return Priority.medium;
      case 3:
        return Priority.high;
      default:
        return Priority.none;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch (obj) {
      case Priority.none:
        writer.writeByte(0);
        break;
      case Priority.low:
        writer.writeByte(1);
        break;
      case Priority.medium:
        writer.writeByte(2);
        break;
      case Priority.high:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
