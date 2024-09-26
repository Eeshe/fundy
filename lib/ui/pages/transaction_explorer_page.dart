import 'package:flutter/material.dart';
import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/transaction.dart';
import 'package:fundy/core/models/transaction_filter.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/account_icon_widget.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/ui/shared/widgets/text_input_widget.dart';
import 'package:fundy/utils/date_time_extension.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:provider/provider.dart';

class TransactionExplorerPage extends StatefulWidget {
  const TransactionExplorerPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionExplorerState();
}

class TransactionExplorerState extends State<TransactionExplorerPage> {
  final TextStyle _labelStyle = const TextStyle(fontSize: 20);
  final double _totalsFontSize = 18;

  final List<Account> _filteredAccounts = [];
  final TextEditingController _descriptionFilterController =
      TextEditingController();

  DateTime? _startingDate;
  DateTime? _endingDate;
  TransactionFilter _selectedTransactionFilter = TransactionFilter.all;

  final List<Transaction> _displayedTransactions = [];

  Widget _createAccountWidget(Account account) {
    return InkWell(
      onTap: () {
        if (_filteredAccounts.contains(account)) {
          _filteredAccounts.remove(account);
        } else {
          _filteredAccounts.add(account);
        }
        setState(() {});
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: _filteredAccounts.contains(account)
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AccountIconWidget(account.iconPath, 40, 40),
            const SizedBox(height: 15),
            Text(
              account.id,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Widget _createAccountSelectorWidget() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        List<Account> accounts =
            accountProvider.accounts.toList(); // Create a copy
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 130,
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) =>
                      _createAccountWidget(accounts[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _createDateButtonWidget(DateTime? date, Function() onPressed) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onBackground),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            Text(
              date!.formatDayMonthYear(),
              style: const TextStyle(fontSize: 16),
            )
          ],
        ));
  }

  Widget _createDateSelectorWidget() {
    DateTime now = DateTime.now();
    _startingDate ??= DateTime(now.year, now.month, 1);
    _endingDate ??= DateTime(now.year, now.month + 1, 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 2,
            child: _createDateButtonWidget(_startingDate, () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _startingDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (pickedDate == null) return;
              if (!context.mounted) return;

              setState(() {
                _startingDate =
                    DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
              });
            })),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.arrow_right_alt,
            color: Theme.of(context).colorScheme.onBackground,
            size: 30,
          ),
        ),
        Expanded(
            flex: 2,
            child: _createDateButtonWidget(_endingDate, () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _startingDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (pickedDate == null) return;
              if (!context.mounted) return;

              setState(() {
                _endingDate =
                    DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
              });
            }))
      ],
    );
  }

  Widget _createDescriptionFilterWidget() {
    return TextInputWidget(
        onChanged: (input) {
          setState(() {});
          return null;
        },
        inputController: _descriptionFilterController,
        hintText: getAppLocalizations(context)!.descriptionFilterInputHint);
  }

  Widget _createTransactionTypeButton(TransactionFilter transactionFilter) {
    Color textColor;
    switch (transactionFilter) {
      case TransactionFilter.all:
        textColor = Theme.of(context).colorScheme.onBackground;
        break;
      case TransactionFilter.income:
        textColor = Theme.of(context).colorScheme.tertiary;
        break;
      case TransactionFilter.outcome:
        textColor = Theme.of(context).colorScheme.error;
        break;
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
        splashFactory: NoSplash.splashFactory,
        textStyle: const TextStyle(fontSize: 16),
        backgroundColor: transactionFilter == _selectedTransactionFilter
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        foregroundColor: textColor,
      ),
      onPressed: () {
        setState(() {
          _selectedTransactionFilter = transactionFilter;
        });
      },
      child: Text(
        transactionFilter.localized(context),
        style: TextStyle(color: textColor),
      ),
    );
  }

  Widget _createTransactionTypeFiltersWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _createTransactionTypeButton(TransactionFilter.all),
        _createTransactionTypeButton(TransactionFilter.income),
        _createTransactionTypeButton(TransactionFilter.outcome),
      ],
    );
  }

  List<Transaction> _computeDisplayedTransactions() {
    int start = DateTime.now().millisecond;
    _displayedTransactions.clear();
    String filteredDescription = _descriptionFilterController.value.text;
    for (Account filteredAccount in _filteredAccounts) {
      //                                                    Create a copy
      List<Transaction> transactions = filteredAccount.transactions.toList();
      transactions.removeWhere((transaction) {
        // Remove all transactions that don't match the description filter
        if (filteredDescription.isNotEmpty &&
            !transaction.description
                .toLowerCase()
                .contains(filteredDescription.toLowerCase())) {
          return true;
        }
        // Remove all transactions that don't match the date filter
        DateTime transactionDate = transaction.date;
        if (transactionDate.isBefore(_startingDate!) ||
            transactionDate.isAfter(_endingDate!)) {
          return true;
        }
        // Remove all transactions that don't match the type filter
        switch (_selectedTransactionFilter) {
          case TransactionFilter.all:
            return false;
          case TransactionFilter.income:
            return transaction.amount < 0;
          case TransactionFilter.outcome:
            return transaction.amount > 0;
        }
      });
      _displayedTransactions.addAll(transactions);
    }
    _displayedTransactions.sort((a, b) => b.date.compareTo(a.date));
    int end = DateTime.now().millisecond;
    print("COMPUTING TOOK ${end - start}ms");
    return _displayedTransactions;
  }

  Widget _createTransactionListWidget() {
    return Consumer<AccountProvider>(
      builder: (context, value, child) {
        _computeDisplayedTransactions();
        return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _displayedTransactions[index].createIconListWidget(true);
            },
            separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
            itemCount: _displayedTransactions.length);
      },
    );
  }

  Widget _createTotalsWidget() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        _computeDisplayedTransactions(); // Should change it later to optimize the app
        double totalIncome = 0;
        double totalOutcome = 0;
        for (Transaction transaction in _displayedTransactions) {
          Account? account = accountProvider.getById(transaction.accountId);
          if (account == null) continue;

          if (transaction.amount > 0) {
            totalIncome += transaction.convertAmount(account.currencyType);
          } else {
            totalOutcome += transaction.convertAmount(account.currencyType);
          }
        }
        double total = totalIncome - totalOutcome;
        return Container(
          height: 50,
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                getAppLocalizations(context)!.totals,
                style: TextStyle(fontSize: _totalsFontSize),
              ),
              Text(
                "-\$${totalOutcome.format()}",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: _totalsFontSize),
              ),
              Text(
                "+\$${totalIncome.format()}",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: _totalsFontSize),
              ),
              const Text(
                "=",
                style: TextStyle(fontSize: 24),
              ),
              Text(
                "\$${total.format()}",
                style: TextStyle(
                    fontSize: _totalsFontSize,
                    color: total > 0
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.error),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.transactionExplorerBar),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
      ),
      body: ScrollablePageWidget(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  getAppLocalizations(context)!
                      .filteredAccounts(_filteredAccounts.length),
                  style: _labelStyle),
              const SizedBox(height: 10),
              _createAccountSelectorWidget(),
              const SizedBox(height: 10),
              Text(
                getAppLocalizations(context)!.date,
                style: _labelStyle,
              ),
              const SizedBox(height: 10),
              _createDateSelectorWidget(),
              const SizedBox(height: 10),
              Text(
                getAppLocalizations(context)!.description,
                style: _labelStyle,
              ),
              _createDescriptionFilterWidget(),
              const SizedBox(height: 10),
              _createTransactionTypeFiltersWidget(),
              _createTransactionListWidget()
            ],
          )),
      bottomNavigationBar: _createTotalsWidget(),
    );
  }
}
