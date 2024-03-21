import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key});

  @override
  State createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _initialBalanceInputController =
      TextEditingController();

  final List<String> _iconPaths = [
    'bdv.png',
    'bancamiga.png',
    'banesco.png',
    'cash.png',
    'paypal.png',
    'usdt.png'
  ];

  final TextStyle _labelStyle = const TextStyle(fontSize: 20);

  String selectedCurrency = 'bs';
  String selectedIconPath = 'bdv.png';

  List<Widget> _createNameInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.name,
        style: _labelStyle,
      ),
      TextInputWidget(
          inputController: _nameInputController,
          hintText: getAppLocalizations(context)!.accountNameHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return getAppLocalizations(context)!.emptyAccountName;
            }
            return null;
          })
    ];
  }

  List<Widget> _createInitialBalanceInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.initialBalance,
        style: const TextStyle(fontSize: 20),
      ),
      TextInputWidget(
        inputController: _initialBalanceInputController,
        hintText: '0.00',
        textInputType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value != null && !value.isNumeric()) {
            return getAppLocalizations(context)!.nonNumberInitialBalance;
          }
          return null;
        },
      )
    ];
  }

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

  List<Widget> _createCurrencyTypeInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.currency,
        style: const TextStyle(fontSize: 20),
      ),
      _createCurrencyRadios(),
    ];
  }

  Widget _createIconSelector() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _iconPaths.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          String iconPath = _iconPaths[index];
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
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: AccountIconWidget(iconPath, 50, 50),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _createAccountIconWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.icon,
        style: const TextStyle(fontSize: 20),
      ),
      _createIconSelector()
    ];
  }

  Widget _createConfirmationButton() {
    return Row(
      children: [
        Expanded(
            child: StyledButtonWidget(
          text: getAppLocalizations(context)!.confirm,
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            String accountName = _nameInputController.text;
            String initialBalanceString = _initialBalanceInputController.text;
            double initialBalance = initialBalanceString.isEmpty
                ? 0
                : double.parse(initialBalanceString);

            CurrencyType currencyType = CurrencyType.values
                .firstWhere((element) => element.name == selectedCurrency);
            List<Transaction> initialTransactions = [];
            if (initialBalance > 0) {
              initialTransactions.add(Transaction(
                  accountName,
                  getAppLocalizations(context)!.initialBalance,
                  DateTime.now(),
                  initialBalance));
            }
            AccountService().save(Account(accountName, initialBalance,
                currencyType, selectedIconPath, initialTransactions));
            Navigator.pop(context);
          },
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.createAccount),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ScrollablePageWidget(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._createNameInputWidgets(),
              const SizedBox(height: 20),
              ..._createInitialBalanceInputWidgets(),
              const SizedBox(height: 20),
              ..._createCurrencyTypeInputWidgets(),
              ..._createAccountIconWidgets(),
              _createConfirmationButton()
            ],
          ),
        ),
      ),
    );
  }
}
