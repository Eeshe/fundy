// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyExpenseAdapter extends TypeAdapter<MonthlyExpense> {
  @override
  final int typeId = 3;

  @override
  MonthlyExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyExpense(
      fields[0] as String,
      fields[1] as double,
      (fields[2] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyExpense obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.paymentRecords);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
