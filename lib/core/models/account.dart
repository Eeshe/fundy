import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/conversion_service.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account {
  @HiveField(0)
  String id;
  @HiveField(1)
  double balance;
  @HiveField(2)
  CurrencyType currencyType;
  @HiveField(3)
  String iconPath;
  @HiveField(4)
  final List<Transaction> transactions;

  Account(this.id, this.balance, this.currencyType, this.iconPath,
      this.transactions);

  String formatUsdBalance() {
    return "${CurrencyType.usd.symbol}${ConversionService.getInstance().currencyToUsd(balance, currencyType.name).format()}";
  }

  String formatBalance(bool convertCurrency) {
    if (!convertCurrency) {
      return "${currencyType.symbol}${balance.format()}";
    }
    return formatUsdBalance();
  }

  void increaseBalance(double amount) {
    balance += amount;
  }

  void decreaseBalance(double amount) {
    balance -= amount;
  }

  void setBalance(double balance) {
    this.balance = balance;
  }

  void _sortTransactions() {
    transactions.sort(
      (a, b) => b.date.compareTo(a.date),
    );
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
    increaseBalance(transaction.amount);
    _sortTransactions();
  }

  void updateTransaction(
      Transaction oldTransaction, Transaction newTransaction) {
    transactions[transactions.indexOf(oldTransaction)] = newTransaction;
    double balanceDifference = newTransaction.amount - oldTransaction.amount;
    increaseBalance(balanceDifference);
    _sortTransactions();
  }

  void deleteTransaction(Transaction transaction) {
    transactions.remove(transaction);
    decreaseBalance(transaction.amount);
    _sortTransactions();
  }

  Widget createListWidget(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushNamed(context, '/account', arguments: this);
        },
        child: Row(
          children: [
            AccountIconWidget(iconPath, 50, 50),
            const SizedBox(width: 10),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  id,
                  style: const TextStyle(fontSize: 24),
                )),
                Text(
                  formatBalance(false),
                  style: const TextStyle(fontSize: 24),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}
