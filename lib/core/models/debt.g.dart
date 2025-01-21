// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 6;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    if (fields[1].runtimeType == DebtType) {
    // Data has pre-contributable structure
    DebtType debtType = fields[1];
    fields[1] = fields[2];
    fields[2] = debtType;
    }
    return Debt(
      fields[0] as String,
      fields[2] as DebtType,
      fields[1] as double,
      fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(4)
      ..writeByte(2)
      ..write(obj.debtType)
      ..writeByte(3)
      ..write(obj.paidAmount)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
