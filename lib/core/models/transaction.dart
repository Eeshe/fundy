import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/services/conversion_service.dart';
import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction {
  @HiveField(0)
  String accountId;
  @HiveField(1)
  String description;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  double amount;

  Transaction(this.accountId, this.description, this.date, this.amount);

  String formatAmount(CurrencyType currencyType) {
    return "${amount > 0 ? '+' : '-'}${currencyType.symbol}${amount.abs().toStringAsFixed(2)}";
  }

  String formatUsdAmount(CurrencyType currencyType) {
    if (currencyType == CurrencyType.usd) return formatAmount(currencyType);

    return "${amount > 0 ? '+' : '-'}${CurrencyType.usd.symbol}${ConversionService.getInstance().convert(amount.abs(), currencyType.name).toStringAsFixed(2)}";
  }
}
