// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contributable.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContributableAdapter extends TypeAdapter<Contributable> {
  @override
  final int typeId = 7;

  @override
  Contributable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contributable(
      fields[0] as String,
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Contributable obj) {
    writer
      ..writeByte(2)
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
      other is ContributableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
