// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyTypeAdapter extends TypeAdapter<CurrencyType> {
  @override
  final int typeId = 1;

  @override
  CurrencyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CurrencyType.bs;
      case 1:
        return CurrencyType.usd;
      case 2:
        return CurrencyType.usdt;
      default:
        return CurrencyType.bs;
    }
  }

  @override
  void write(BinaryWriter writer, CurrencyType obj) {
    switch (obj) {
      case CurrencyType.bs:
        writer.writeByte(0);
        break;
      case CurrencyType.usd:
        writer.writeByte(1);
        break;
      case CurrencyType.usdt:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
