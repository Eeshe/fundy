import 'package:hive/hive.dart';

part 'currency_type.g.dart';

@HiveType(typeId: 1)
enum CurrencyType {
  @HiveField(0)
  bs(symbol: "Bs"),
  @HiveField(1)
  usd(symbol: "\$"),
  @HiveField(2)
  usdt(symbol: "USDT");

  const CurrencyType({required this.symbol});

  final String symbol;
}
