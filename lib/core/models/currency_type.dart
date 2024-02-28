import 'package:hive/hive.dart';

part 'currency_type.g.dart';

@HiveType(typeId: 1)
enum CurrencyType {
  @HiveField(0)
  bs("Bs", "Bs"),
  @HiveField(1)
  usd("\$", "USD"),
  @HiveField(2)
  usdt("USDT", "USDT");

  const CurrencyType(this.symbol, this.displayName);

  final String symbol;
  final String displayName;
}
