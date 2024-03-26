import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/services/conversion_service.dart';
import 'package:finman/ui/pages/transaction_form_page.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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
  @HiveField(4)
  bool isMobilePayment;

  Transaction(this.accountId, this.description, this.date, this.amount,
      this.isMobilePayment);

  String formatAmount(CurrencyType currencyType) {
    return "${amount > 0 ? '+' : '-'}${currencyType.symbol}${amount.abs().format()}";
  }

  String formatUsdAmount(CurrencyType currencyType) {
    if (currencyType == CurrencyType.usd) return formatAmount(currencyType);

    return "${amount > 0 ? '+' : '-'}${CurrencyType.usd.symbol}${ConversionService.getInstance().currencyToUsd(amount.abs(), currencyType.name).format()}";
  }

  Widget createListWidget(BuildContext context, Account account,
      bool convertCurrency, Function() redrawCallback) {
    CurrencyType currencyType = account.currencyType;
    return InkWell(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionFormPage(account, this),
            ));
        redrawCallback();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                DateFormat('dd/MM/yyyy kk:mm').format(date),
                style: const TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          )),
          Text(
            convertCurrency
                ? formatUsdAmount(currencyType)
                : formatAmount(currencyType),
            style: TextStyle(
              fontSize: 20,
              color: amount >= 0
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.error,
            ),
          )
        ],
      ),
    );
  }
}
