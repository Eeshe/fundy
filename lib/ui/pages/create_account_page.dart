import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _initialBalanceInputController =
      TextEditingController();
  final List<String> iconPaths = [
    'bdv.png',
    'bancamiga.png',
    'banesco.png',
    'cash.png',
    'paypal.png',
    'usdt.png'
  ];

  String selectedCurrency = 'bs';
  String selectedIconPath = 'bdv.png';

  Row _createCurrencyRadios() {
    List<Expanded> radios = [];
    for (CurrencyType currencyType in CurrencyType.values) {
      radios.add(Expanded(
        flex: 1,
        child: Row(
          children: [
            Radio(
                value: currencyType.name,
                groupValue: selectedCurrency,
                onChanged: (value) =>
                    setState(() => selectedCurrency = value.toString())),
            Text(
              currencyType.name.toUpperCase(),
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ));
    }
    return Row(children: radios);
  }

  Widget _createIconSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: iconPaths.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          String iconPath = iconPaths[index];
          return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIconPath = iconPath;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedIconPath == iconPath
                      ? Colors.blueGrey // Highlight selected icon
                      : Colors.transparent,
                ),
                child: AccountIconWidget(iconPath, 50, 50),
              ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.createAccount),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getAppLocalizations(context)!.name,
                  style: const TextStyle(fontSize: 20),
                ),
                TextFormField(
                  controller: _nameInputController,
                  decoration: InputDecoration(
                    hintText: getAppLocalizations(context)!.accountNameHint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getAppLocalizations(context)!.emptyAccountName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  getAppLocalizations(context)!.initialBalance,
                  style: const TextStyle(fontSize: 20),
                ),
                TextFormField(
                  controller: _initialBalanceInputController,
                  decoration: const InputDecoration(
                    hintText: '0.00',
                  ),
                  validator: (value) {
                    if (RegExp(r'[A-Za-z,]+').hasMatch(value.toString())) {
                      return getAppLocalizations(context)!
                          .nonNumberInitialBalance;
                    }
                    return null;
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),
                Text(
                  getAppLocalizations(context)!.currency,
                  style: const TextStyle(fontSize: 20),
                ),
                _createCurrencyRadios(),
                Text(
                  getAppLocalizations(context)!.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                _createIconSelector(),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;

                              String accountName = _nameInputController.text;
                              String initialBalanceString =
                                  _initialBalanceInputController.text;
                              double initialBalance =
                                  initialBalanceString.isEmpty
                                      ? 0
                                      : double.parse(initialBalanceString);

                              CurrencyType currencyType = CurrencyType.values
                                  .firstWhere((element) =>
                                      element.name == selectedCurrency);
                              List<Transaction> initialTransactions = [];
                              if (initialBalance > 0) {
                                initialTransactions.add(Transaction(
                                    accountName,
                                    getAppLocalizations(context)!
                                        .initialBalance,
                                    DateTime.now(),
                                    initialBalance));
                              }
                              AccountService().save(Account(
                                  accountName,
                                  initialBalance,
                                  currencyType,
                                  selectedIconPath,
                                  initialTransactions));
                              Navigator.pop(context);
                            },
                            child: Text(getAppLocalizations(context)!.confirm)))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
