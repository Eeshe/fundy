import 'package:flutter/material.dart';
import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/currency_type.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/core/services/conversion_service.dart';
import 'package:fundy/ui/pages/transaction_form_page.dart';
import 'package:fundy/ui/shared/widgets/account_icon_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

    return "${amount > 0 ? '+' : '-'}${CurrencyType.usd.symbol}${convertAmount(currencyType).format()}";
  }

  double convertAmount(CurrencyType currencyType) {
    if (currencyType == CurrencyType.usd) return amount.abs();

    return ConversionService.getInstance().currencyToUsd(amount.abs(), currencyType.name);
  }

  Widget createListWidget(bool convertCurrency) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        Account? account = accountProvider.getById(accountId);
        if (account == null) {
          return const SizedBox();
        }
        CurrencyType currencyType = account.currencyType;
        return InkWell(
          onTap: () {},
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pushNamed(context, '/transaction_form',
                  arguments: TransactionFormArguments(this, account));
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
                        ? Theme
                        .of(context)
                        .colorScheme
                        .tertiary
                        : Theme
                        .of(context)
                        .colorScheme
                        .error,
                  ),
                )
              ],
            ),
          ),
        );
      },);
  }

  Widget createIconListWidget(bool convertCurrency) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        Account? account = accountProvider.getById(accountId);
        if (account == null) return const SizedBox();

        CurrencyType currencyType = account.currencyType;
        Color textColor;
          textColor = amount >= 0
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.error;
        return InkWell(
          onTap: () {},
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pushNamed(context, '/transaction_form',
                  arguments: TransactionFormArguments(this, account));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: AccountIconWidget(account.iconPath, 50, 50)),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        account.id,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy kk:mm').format(date),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    convertCurrency
                        ? formatUsdAmount(currencyType)
                        : formatAmount(currencyType),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
