// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtTypeAdapter extends TypeAdapter<DebtType> {
  @override
  final int typeId = 5;

  @override
  DebtType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DebtType.own;
      case 1:
        return DebtType.other;
      default:
        return DebtType.own;
    }
  }

  @override
  void write(BinaryWriter writer, DebtType obj) {
    switch (obj) {
      case DebtType.own:
        writer.writeByte(0);
        break;
      case DebtType.other:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
