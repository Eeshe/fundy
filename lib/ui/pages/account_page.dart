import 'dart:math';

import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/models/saving.dart';
import 'package:finman/core/providers/account_provider.dart';
import 'package:finman/core/services/conversion_service.dart';
import 'package:finman/core/services/saving_service.dart';
import 'package:finman/ui/pages/saving_form_page.dart';
import 'package:finman/ui/pages/transaction_form_page.dart';
import 'package:finman/ui/pages/update_account_balance_dialog.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  final Account _account;

  const AccountPage(this._account, {super.key});

  @override
  State<StatefulWidget> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final TextStyle _labelStyle =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

  bool _convertCurrency = false;
  List<Saving>? _accountSavings;

  Future<void> _fetchAccountSavings() async {
    Account account = widget._account;
    List<Saving> accountSavings = [];
    for (Saving saving in await SavingService().fetchAll()) {
      if (saving.accountId != account.id) continue;

      accountSavings.add(saving);
    }
    _accountSavings = accountSavings;
  }

  Widget _createBalancesWidget() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        Account account = widget._account;
        double bruteBalance = account.balance;
        double netBalance = bruteBalance;
        for (Saving saving in _accountSavings!) {
          netBalance -= ConversionService().usdToCurrency(
              saving.calculateRemainingAmount(), account.currencyType.name);
        }
        if (_convertCurrency && bruteBalance != netBalance) {
          netBalance = ConversionService.getInstance()
              .currencyToUsd(netBalance, account.currencyType.name);
        }
        List<Widget> netBalanceWidgets = [];
        if (bruteBalance != netBalance) {
          netBalanceWidgets.addAll([
            Text(
              getAppLocalizations(context)!.netBalance,
              style: _labelStyle,
            ),
            Text(
              "${_convertCurrency ? CurrencyType.usd.symbol : account.currencyType.symbol}${netBalance.format()}",
              style: const TextStyle(fontSize: 20),
            )
          ]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              getAppLocalizations(context)!.bruteBalance,
              style: _labelStyle,
            ),
            Text(
              account.formatBalance(_convertCurrency),
              style: const TextStyle(fontSize: 20),
            ),
            ...netBalanceWidgets
          ],
        );
      },
    );
  }

  Widget _createConversionSwitch() {
    if (widget._account.currencyType == CurrencyType.usd) {
      return const SizedBox();
    }

    return Switch(
      value: _convertCurrency,
      onChanged: (value) {
        setState(() {
          _convertCurrency = value;
        });
      },
      thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
          (states) => const Icon(Icons.attach_money)),
    );
  }

  Widget _createTransactionListWidget() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        Account account = widget._account;
        double screenHeight = MediaQuery.of(context).size.height;
        double containerHeight =
            min(screenHeight * 0.3, account.transactions.length * 65);
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getAppLocalizations(context)!.transactions,
                  style: _labelStyle,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionFormPage(account, null),
                        ));
                  },
                  child: Text(
                    getAppLocalizations(context)!.newText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                )
              ],
            ),
            Container(
              height: containerHeight,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(5),
                  itemBuilder: (context, index) => account.transactions[index]
                      .createListWidget(context, account, _convertCurrency),
                  separatorBuilder: (context, index) =>
                      Divider(color: Theme.of(context).colorScheme.primary),
                  itemCount: account.transactions.length),
            )
          ],
        );
      },
    );
  }

  Widget _createSavingListWidget() {
    if (_accountSavings!.isEmpty) return const SizedBox();

    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight =
        min(screenHeight * 0.3, _accountSavings!.length * 65);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getAppLocalizations(context)!.savings,
              style: _labelStyle,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SavingFormPage(null, widget._account),
                    ));
                setState(() {});
              },
              child: Text(
                getAppLocalizations(context)!.newText,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            )
          ],
        ),
        Container(
          height: containerHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(5),
              itemBuilder: (context, index) => _accountSavings![index]
                  .createListWidget(
                      context, widget._account, () => setState(() {})),
              separatorBuilder: (context, index) =>
                  Divider(color: Theme.of(context).colorScheme.primary),
              itemCount: _accountSavings!.length),
        )
      ],
    );
  }

  Widget _createUpdateBalanceButton() {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onBackground,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => UpdateBalanceDialog(widget._account));
          },
          child: Text(
            getAppLocalizations(context)!.updateBalance,
            style: const TextStyle(fontSize: 20),
          ),
        ))
      ],
    );
  }

  Widget _createDeleteButton() {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(getAppLocalizations(context)!.confirmation),
                  content: Text(
                      getAppLocalizations(context)!.deleteAccountConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getAppLocalizations(context)!.cancel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AccountProvider>(context, listen: false)
                            .delete(widget._account);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        getAppLocalizations(context)!.delete,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            getAppLocalizations(context)!.delete,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = widget._account;
    return FutureBuilder(
      future: _fetchAccountSavings(),
      builder: (context, snapshot) {
        if (_accountSavings == null) return const SizedBox();

        return Scaffold(
          appBar: AppBar(
            title: Text(account.id),
            backgroundColor: Theme.of(context).colorScheme.primary,
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          resizeToAvoidBottomInset: false,
          body: ScrollablePageWidget(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Center(child: AccountIconWidget(account.iconPath, 100, 100)),
                  _createBalancesWidget(),
                  _createConversionSwitch(),
                  _createTransactionListWidget(),
                  _createSavingListWidget(),
                  _createUpdateBalanceButton(),
                  _createDeleteButton()
                ],
              )),
        );
      },
    );
  }
}
