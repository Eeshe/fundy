import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/models/debt.dart';
import 'package:finman/core/models/debt_type.dart';
import 'package:finman/core/models/monthly_expense.dart';
import 'package:finman/core/models/saving.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/core/services/conversion_service.dart';
import 'package:finman/core/services/debt_service.dart';
import 'package:finman/core/services/monthly_expense_service.dart';
import 'package:finman/core/services/saving_service.dart';
import 'package:finman/ui/pages/account_list_page.dart';
import 'package:finman/ui/pages/debt_list_page.dart';
import 'package:finman/ui/pages/exchange_page.dart';
import 'package:finman/ui/pages/expense_list_page.dart';
import 'package:finman/ui/pages/saving_list_page.dart';
import 'package:finman/ui/pages/settings_page.dart';
import 'package:finman/ui/pages/transaction_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:finman/ui/shared/widgets/expandable_fab_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  AppBar _createAppBar() {
    return AppBar(
      title: const Text("FinMan"),
      centerTitle: true,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      actions: [
        IconButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
              setState(() {});
            },
            icon: const Icon(Icons.settings))
      ],
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Future<void> _computeBalances() async {
    final ConversionService conversionService = ConversionService.getInstance();
    double bruteBalance = 0;
    for (Account account in (await AccountService.getInstance().fetchAll())) {
      if (account.currencyType == CurrencyType.usd) {
        bruteBalance += account.balance;
        continue;
      }
      bruteBalance += conversionService.convert(
          account.balance, account.currencyType.name.toLowerCase());
    }
    _bruteBalance = bruteBalance;
    // Subtract monthly expenses
    double remainingMonthlyExpenses = 0;
    for (MonthlyExpense monthlyExpense
        in (await MonthlyExpenseService().fetchAll())) {
      remainingMonthlyExpenses +=
          monthlyExpense.getRemainingPayment(DateTime.now());
    }
    // Subtract own debts
    double remainingDebts = 0;
    for (Debt debt in (await DebtService().fetchAll())) {
      if (debt.debtType == DebtType.other) continue;

      remainingDebts += debt.calculateRemainingAmount();
    }
    _netBalance = bruteBalance - remainingMonthlyExpenses - remainingDebts;

    double remainingSavings = 0;
    for (Saving saving in (await SavingService().fetchAll())) {
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
          "\$${balance.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 25,
          ),
        )
      ],
    );
  }

  Widget _createBalancesOverviewWidget() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: FutureBuilder(
        future: _computeBalances(),
        builder: (context, snapshot) {
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
      ),
    );
  }

  Widget _createPageButton(
      Widget destination, IconData iconData, String label) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => destination,
                    ));
                setState(() {});
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
        _createPageButton(const AccountListPage(), Icons.account_box_outlined,
            getAppLocalizations(context)!.accounts),
        _createPageButton(const ExpenseListPage(), Icons.money_off,
            getAppLocalizations(context)!.expenses),
        _createPageButton(const SavingListPage(), Icons.savings,
            getAppLocalizations(context)!.savings),
        _createPageButton(const DebtListPage(), Icons.account_balance_wallet,
            getAppLocalizations(context)!.debts),
      ],
    );
  }

  Future<void> _computeRecentTransactions() async {
    List<Transaction> transactions = [];
    for (Account account in (await AccountService.getInstance().fetchAll())) {
      transactions.addAll(account.transactions);
    }
    transactions.sort((a, b) => b.date.compareTo(a.date));
    _recentTransactions = transactions;
  }

  Widget _createTransactionWidget(Transaction transaction) {
    return FutureBuilder<Account?>(
      future: AccountService.getInstance().fetch(transaction.accountId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox();
        }
        Account account = snapshot.data as Account;
        CurrencyType currencyType = account.currencyType;
        double amount = transaction.amount;
        return InkWell(
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionFormPage(account, transaction),
                ));
            setState(() {});
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1, child: AccountIconWidget(account.iconPath, 50, 50)),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      account.id,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy kk:mm').format(transaction.date),
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
                  transaction.formatAmount(currencyType),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 20,
                    color: amount >= 0
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _createRecentTransactionsWidget() {
    return FutureBuilder(
      future: _computeRecentTransactions(),
      builder: (context, snapshot) {
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
                const Icon(
                  Icons.search_off,
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
              Text(
                getAppLocalizations(context)!.recentTransactions,
                style: const TextStyle(
                  fontSize: 26,
                ),
              ),
              Expanded(
                  child: ListView.separated(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      itemBuilder: (context, index) {
                        return _createTransactionWidget(
                            _recentTransactions![index]);
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
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionFormPage(null, null),
                ));
            setState(() {});
          },
          icon: Icon(
            Icons.attach_money,
            color: onBackgroundColor,
          ),
          backgroundColor: primaryColor,
        ),
        ActionButton(
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExchangePage(),
                ));
            setState(() {});
          },
          icon: Icon(
            Icons.currency_exchange,
            color: onBackgroundColor,
          ),
          backgroundColor: primaryColor,
        ),
      ],
      child: const Icon(Icons.add),
    );
    // return ExpandableFab(
    //   openButtonBuilder: RotateFloatingActionButtonBuilder(
    //     heroTag: "openFab",
    //     child: const Icon(Icons.add),
    //     backgroundColor: primaryColor,
    //     fabSize: ExpandableFabSize.regular,
    //   ),
    //   closeButtonBuilder: RotateFloatingActionButtonBuilder(
    //       heroTag: "closeFab",
    //       child: const Icon(Icons.close),
    //       fabSize: ExpandableFabSize.regular,
    //       backgroundColor: primaryColor,
    //       shape: const CircleBorder()),
    //   children: [
    //     FloatingActionButton.small(
    //       heroTag: "newTransactionFab",
    //       backgroundColor: Theme.of(context).colorScheme.primary,
    //       child: const Icon(Icons.attach_money),
    //       onPressed: () async {
    //         ExpandableFabState? fabState = _key.currentState;
    //         if (fabState != null) {
    //           fabState.toggle();
    //         }
    //         await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => TransactionFormPage(null, null),
    //             ));
    //         setState(() {});
    //       },
    //     ),
    //     FloatingActionButton.small(
    //       heroTag: "newExchangeFab",
    //       backgroundColor: Theme.of(context).colorScheme.primary,
    //       child: const Icon(Icons.currency_exchange),
    //       onPressed: () async {
    //         ExpandableFabState? fabState = _key.currentState;
    //         if (fabState != null) {
    //           fabState.toggle();
    //         }
    //         await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => const ExchangePage(),
    //             ));
    //         setState(() {});
    //       },
    //     )
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _createBalancesOverviewWidget(),
          const SizedBox(height: 10),
          _createPageButtons(),
          const SizedBox(height: 10),
          _createRecentTransactionsWidget(),
        ],
      ),
      floatingActionButton: _createFloatingActionButton(),
    );
  }
}
