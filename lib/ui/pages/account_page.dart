import 'dart:math';

import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/currency_type.dart';
import 'package:fundy/core/models/saving.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/core/providers/saving_provider.dart';
import 'package:fundy/core/services/conversion_service.dart';
import 'package:fundy/ui/pages/saving_form_page.dart';
import 'package:fundy/ui/pages/transaction_form_page.dart';
import 'package:fundy/ui/pages/update_account_balance_dialog.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/account_icon_widget.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  final Account account;

  const AccountPage({super.key, required this.account});

  @override
  State<StatefulWidget> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final TextStyle _labelStyle =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

  bool _convertCurrency = false;

  Widget _createBalancesWidget() {
    return Consumer2<AccountProvider, SavingProvider>(
      builder: (context, accountProvider, savingProvider, child) {
        double bruteBalance = widget.account.balance;
        double netBalance = bruteBalance;
        for (Saving saving in savingProvider.getByAccount(widget.account)) {
          netBalance -= ConversionService().usdToCurrency(
              saving.calculateRemainingAmount(),
              widget.account.currencyType.name);
        }
        if (_convertCurrency && bruteBalance != netBalance) {
          netBalance = ConversionService.getInstance()
              .currencyToUsd(netBalance, widget.account.currencyType.name);
        }
        List<Widget> netBalanceWidgets = [];
        if (bruteBalance != netBalance) {
          netBalanceWidgets.addAll([
            Text(
              getAppLocalizations(context)!.netBalance,
              style: _labelStyle,
            ),
            Text(
              "${_convertCurrency ? CurrencyType.usd.symbol : widget.account.currencyType.symbol}${netBalance.format()}",
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
              widget.account.formatBalance(_convertCurrency),
              style: const TextStyle(fontSize: 20),
            ),
            ...netBalanceWidgets
          ],
        );
      },
    );
  }

  Widget _createConversionSwitch() {
    if (widget.account.currencyType == CurrencyType.usd) {
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
        double screenHeight = MediaQuery.of(context).size.height;
        double containerHeight =
            min(screenHeight * 0.3, widget.account.transactions.length * 65);
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
                    Navigator.pushNamed(context, '/transaction_form',
                        arguments:
                            TransactionFormArguments(null, widget.account));
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
                  itemBuilder: (context, index) =>
                      widget.account.transactions[index].createListWidget(_convertCurrency),
                  separatorBuilder: (context, index) =>
                      Divider(color: Theme.of(context).colorScheme.primary),
                  itemCount: widget.account.transactions.length),
            )
          ],
        );
      },
    );
  }

  Widget _createSavingListWidget() {
    return Consumer<SavingProvider>(
      builder: (context, savingProvider, child) {
        List<Saving> savings = savingProvider.getByAccount(widget.account);
        if (savings.isEmpty) return const SizedBox();

        double screenHeight = MediaQuery.of(context).size.height;
        double containerHeight = min(screenHeight * 0.3, savings.length * 65);
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/saving_form',
                        arguments: SavingFormArguments(null, widget.account));
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
                  itemBuilder: (context, index) =>
                      savings[index].createListWidget(context, widget.account),
                  separatorBuilder: (context, index) =>
                      Divider(color: Theme.of(context).colorScheme.primary),
                  itemCount: savings.length),
            )
          ],
        );
      },
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
                builder: (context) => UpdateBalanceDialog(widget.account));
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
                            .delete(widget.account);
                        SavingProvider savingProvider =
                            Provider.of<SavingProvider>(context, listen: false);
                        for (var saving
                            in savingProvider.getByAccount(widget.account)) {
                          savingProvider.delete(saving);
                        }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.id),
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          resizeToAvoidBottomInset: false,
          body: ScrollablePageWidget(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
              Center(
                  child: AccountIconWidget(widget.account.iconPath, 100, 100)),
              _createBalancesWidget(),
              _createConversionSwitch(),
                  _createTransactionListWidget(),
                  _createSavingListWidget(),
                  _createUpdateBalanceButton(),
                  _createDeleteButton()
                ],
              )),
        );
  }
}
