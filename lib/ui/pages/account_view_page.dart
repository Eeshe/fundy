import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/pages/transaction_form_page.dart';
import 'package:finman/ui/pages/update_balance_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/transaction.dart';

class AccountViewPage extends StatefulWidget {
  final Account _account;

  const AccountViewPage(this._account, {super.key});

  @override
  State<StatefulWidget> createState() => AccountViewPageState();
}

class AccountViewPageState extends State<AccountViewPage> {
  bool _convertCurrency = false;

  Widget _createConversionSwitch() {
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

  Widget _createTransactionWidget(Transaction transaction) {
    CurrencyType currencyType = widget._account.currencyType;
    double amount = transaction.amount;
    return InkWell(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionFormPage(widget._account, transaction),
            ));
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  DateFormat('dd/MM/yyyy kk:mm').format(transaction.date),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                )
              ],
            )),
            Text(
              _convertCurrency
                  ? transaction.formatUsdAmount(currencyType)
                  : transaction.formatAmount(currencyType),
              style: TextStyle(
                fontSize: 20,
                color: amount >= 0 ? Colors.green : Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Account account = widget._account;
    return Scaffold(
      appBar: AppBar(
        title: Text(account.id),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child:
                  Center(child: AccountIconWidget(account.iconPath, 100, 100)),
            ),
            Expanded(
              flex: 1,
              child: Text(
                account.formatBalance(_convertCurrency),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _createConversionSwitch(),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getAppLocalizations(context)!.transactions,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TransactionFormPage(account, null),
                          ));
                      setState(() {});
                    },
                    child: Text(getAppLocalizations(context)!.newText),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        _createTransactionWidget(account.transactions[index]),
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: account.transactions.length),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UpdateBalancePage(widget._account)));
                        setState(() {});
                      },
                      child: Text(
                        getAppLocalizations(context)!.updateBalance,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  getAppLocalizations(context)!.confirmation),
                              content: Text(getAppLocalizations(context)!
                                  .deleteAccountConfirmation),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    AccountService().delete(account);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child:
                                      Text(getAppLocalizations(context)!.yes),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(getAppLocalizations(context)!.no),
                                )
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                      child: Text(
                        getAppLocalizations(context)!.delete,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
