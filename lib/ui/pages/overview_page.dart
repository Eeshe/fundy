import 'package:flutter/material.dart';
import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/currency_type.dart';
import 'package:fundy/core/models/debt.dart';
import 'package:fundy/core/models/debt_type.dart';
import 'package:fundy/core/models/monthly_expense.dart';
import 'package:fundy/core/models/saving.dart';
import 'package:fundy/core/models/transaction.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/core/providers/debt_provider.dart';
import 'package:fundy/core/providers/monthly_expense_provider.dart';
import 'package:fundy/core/services/conversion_service.dart';
import 'package:fundy/ui/pages/transaction_form_page.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/expandable_fab_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:provider/provider.dart';

import '../../core/providers/saving_provider.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<StatefulWidget> createState() => OverviewPageState();
}

class OverviewPageState extends State<OverviewPage> {
  double? _bruteBalance;
  double? _netBalance;
  double? _netBalanceMinusSavings;
  List<Transaction>? _recentTransactions;

  bool _showBalances = false;

  AppBar _createAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _showBalances = !_showBalances;
            });
          },
          icon: Icon(_showBalances ? Icons.visibility_off : Icons.visibility),
        ),
        IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings))
      ],
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _computeBalances() {
    final ConversionService conversionService = ConversionService.getInstance();
    double bruteBalance = 0;
    for (Account account
        in Provider.of<AccountProvider>(context, listen: false).accounts) {
      if (account.currencyType == CurrencyType.usd) {
        bruteBalance += account.balance;
        continue;
      }
      bruteBalance += conversionService.currencyToUsd(
          account.balance, account.currencyType.name.toLowerCase());
    }
    _bruteBalance = bruteBalance;
    // Subtract monthly expenses
    double remainingMonthlyExpenses = 0;
    for (MonthlyExpense monthlyExpense
        in Provider.of<MonthlyExpenseProvider>(context, listen: false)
            .monthlyExpenses) {
      remainingMonthlyExpenses +=
          monthlyExpense.getRemainingPayment(DateTime.now());
    }
    // Subtract own debts
    double remainingDebts = 0;
    for (Debt debt in Provider.of<DebtProvider>(context, listen: false).debts) {
      if (debt.debtType == DebtType.other) continue;

      remainingDebts += debt.calculateRemainingAmount();
    }
    _netBalance = bruteBalance - remainingMonthlyExpenses - remainingDebts;

    double remainingSavings = 0;
    for (Saving saving
        in Provider.of<SavingProvider>(context, listen: false).savings) {
      remainingSavings += saving.calculateRemainingAmount();
    }
    _netBalanceMinusSavings = bruteBalance -
        remainingMonthlyExpenses -
        remainingDebts -
        remainingSavings;
  }

  Widget _createBalanceOverviewWidget(double balance, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        Text(
          !_showBalances ? "\$******" : "\$${balance.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 25,
          ),
        )
      ],
    );
  }

  Widget _createBalancesOverviewWidget() {
    return Consumer4<AccountProvider, MonthlyExpenseProvider, SavingProvider,
        DebtProvider>(
      builder: (context, value, value2, value3, value4, child) {
        _computeBalances();
        if (_bruteBalance == null ||
            _netBalance == null ||
            _netBalanceMinusSavings == null) {
          return Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(getAppLocalizations(context)!.computingBalances)
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _createBalanceOverviewWidget(
                _bruteBalance!, getAppLocalizations(context)!.bruteBalance),
            _createBalanceOverviewWidget(
                _netBalance!, getAppLocalizations(context)!.netBalance),
            _createBalanceOverviewWidget(_netBalanceMinusSavings!,
                getAppLocalizations(context)!.usableBalance),
          ],
        );
      },
    );
  }

  Widget _createDollarRateWidget(String text, double rate) {
    Widget rateWidget = rate == 0 || rate == double.infinity
        ? CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onBackground,
          )
        : Text(
            "Bs${rate.format()}",
            style: const TextStyle(fontSize: 25),
          );
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
        rateWidget
      ],
    );
  }

  Widget _createDollarRatesWidget() {
    return FutureBuilder(
      future: ConversionService.updateFuture,
      builder: (context, snapshot) {
        ConversionService conversionService = ConversionService();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _createDollarRateWidget(getAppLocalizations(context)!.binanceDollar,
                conversionService.fetchRate('binance')),
            _createDollarRateWidget(getAppLocalizations(context)!.euroPrice,
                conversionService.fetchRate('euro')),
            _createDollarRateWidget(getAppLocalizations(context)!.bcvDollar,
                conversionService.fetchRate('bcv')),
          ],
        );
      },
    );
  }

  Widget _createTopPanelWidget() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _createBalancesOverviewWidget(),
          _createDollarRatesWidget(),
        ],
      ),
    );
  }

  Widget _createPageButton(
      String destination, IconData iconData, String label) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, destination);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
              child: Icon(
                iconData,
                size: 30,
              )),
        ),
        Text(label),
      ],
    );
  }

  Widget _createPageButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _createPageButton('/account_list', Icons.account_box_outlined,
            getAppLocalizations(context)!.accounts),
        _createPageButton('/expense_list', Icons.money_off,
            getAppLocalizations(context)!.expenses),
        _createPageButton('/saving_list', Icons.savings,
            getAppLocalizations(context)!.savings),
        _createPageButton('/debt_list', Icons.account_balance_wallet,
            getAppLocalizations(context)!.debts),
      ],
    );
  }

  void _computeRecentTransactions(List<Account> accounts) {
    List<Transaction> transactions = [];
    for (Account account in accounts) {
      transactions.addAll(account.transactions);
    }
    transactions.sort((a, b) => b.date.compareTo(a.date));
    _recentTransactions = transactions;
  }

  Widget _createRecentTransactionsWidget() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        _computeRecentTransactions(accountProvider.accounts);
        if (_recentTransactions == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(getAppLocalizations(context)!.fetchingTransactions)
            ],
          );
        }
        if (_recentTransactions!.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  color: Theme.of(context).colorScheme.error,
                  size: 50,
                ),
                Text(
                  getAppLocalizations(context)!.noRecentTransactions,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
        }
        return Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getAppLocalizations(context)!.recentTransactions,
                        style: const TextStyle(fontSize: 20)),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, "/transaction_explorer"),
                      child: Text(
                        getAppLocalizations(context)!.transactionExplorerButton,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: ListView.separated(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      itemBuilder: (context, index) {
                        return _recentTransactions![index]
                            .createIconListWidget(_showBalances, false);
                      },
                      separatorBuilder: (context, index) => Divider(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      itemCount: _recentTransactions!.length))
            ],
          ),
        );
      },
    );
  }

  ExpandableFab _createFloatingActionButton() {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    return ExpandableFab(
      distance: 80,
      backgroundColor: primaryColor,
      actionButtons: [
        ActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/transaction_form',
                arguments: TransactionFormArguments(null, null));
          },
          icon: Icon(
            Icons.attach_money,
            color: onBackgroundColor,
          ),
          backgroundColor: primaryColor,
        ),
        ActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/exchange_form');
          },
          icon: Icon(
            Icons.currency_exchange,
            color: onBackgroundColor,
          ),
          backgroundColor: primaryColor,
        ),
        ActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/conversion_calculator');
          },
          icon: Icon(
            Icons.calculate_outlined,
            color: onBackgroundColor,
          ),
          backgroundColor: primaryColor,
        ),
      ],
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _createTopPanelWidget(),
          const SizedBox(height: 10),
          _createPageButtons(),
          _createRecentTransactionsWidget(),
        ],
      ),
      floatingActionButton: _createFloatingActionButton(),
    );
  }
}
