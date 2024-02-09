import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:flutter/material.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<StatefulWidget> createState() => ExchangePageState();
}

class ExchangePageState extends State<ExchangePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startingAmountController =
      TextEditingController();
  final TextEditingController _finalAmountController = TextEditingController();

  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  Account? _startingAccount;
  Account? _finalAccount;

  Widget _createStartingAccountInput() {
    return Row(
      children: [
        Expanded(
            child: AccountDropdownButtonWidget(
          _startingAccount,
          (account) {
            setState(() {
              _startingAccount = account;
            });
          },
        )),
        Expanded(
          child: TextFormField(
            controller: _startingAmountController,
            decoration: const InputDecoration(
              hintText: '0.00',
            ),
            validator: (value) {
              if (_startingAccount == null) {
                return getAppLocalizations(context)!.emptyStartingAccount;
              }
              if (value == null || value.isEmpty) {
                return getAppLocalizations(context)!.emptyExchangeAmount;
              }
              if (RegExp(r'[A-Za-z,]+').hasMatch(value.toString())) {
                return getAppLocalizations(context)!.nonNumberAmount;
              }
              double amount = double.parse(value);
              if (amount < 0) {
                return getAppLocalizations(context)!.negativeBalanceAmount;
              }
              if (_startingAccount!.balance - amount < 0) {
                return getAppLocalizations(context)!.negativeBalanceAmount;
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
        )
      ],
    );
  }

  Widget _createRateCalculationWidget() {
    RegExp regex = RegExp(r'[A-Za-z,]+');
    String startingAmountString = _startingAmountController.text;
    String finalAmountString = _finalAmountController.text;
    double rate;
    if (startingAmountString.isEmpty ||
        finalAmountString.isEmpty ||
        regex.hasMatch(startingAmountString) ||
        regex.hasMatch(finalAmountString)) {
      rate = 0;
    } else {
      double startingAmount = double.parse(startingAmountString);
      double finalAmount = double.parse(finalAmountString);
      rate = finalAmount / startingAmount;
    }
    return Text(rate.toStringAsFixed(2), style: const TextStyle(fontSize: 20));
  }

  Widget _createFinalAccountInput() {
    return Row(
      children: [
        Expanded(
            child: AccountDropdownButtonWidget(
          _finalAccount,
          (account) {
            setState(() {
              _finalAccount = account;
            });
          },
        )),
        Expanded(
          child: TextFormField(
            controller: _finalAmountController,
            decoration: const InputDecoration(
              hintText: '0.00',
            ),
            validator: (value) {
              if (_finalAccount == null) {
                return getAppLocalizations(context)!.emptyFinalAccount;
              }
              if (value == null || value.isEmpty) {
                return getAppLocalizations(context)!.emptyExchangeAmount;
              }
              if (RegExp(r'[A-Za-z,]+').hasMatch(value.toString())) {
                return getAppLocalizations(context)!.nonNumberAmount;
              }
              double amount = double.parse(value);
              if (amount < 0) {
                return getAppLocalizations(context)!.negativeBalanceAmount;
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
        )
      ],
    );
  }

  Widget _createSaveButton() {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  if (_startingAccount == _finalAccount) return;

                  double startingAmount =
                      double.parse(_startingAmountController.text);
                  double finalAmount =
                      double.parse(_finalAmountController.text);

                  _startingAccount!.addTransaction(Transaction(
                      _startingAccount!.id,
                      getAppLocalizations(context)!.exchangeDescription(
                          _startingAccount!.id, _finalAccount!.id),
                      DateTime.now(),
                      -startingAmount));
                  _finalAccount!.addTransaction(Transaction(
                      _finalAccount!.id,
                      getAppLocalizations(context)!.exchangeDescription(
                          _startingAccount!.id, _finalAccount!.id),
                      DateTime.now(),
                      finalAmount));

                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.pop(context);
                },
                child: Text(getAppLocalizations(context)!.save)))
      ],
    );
  }

  Widget _createCancelButton() {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(getAppLocalizations(context)!.cancel),
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getAppLocalizations(context)!.fromExchange,
                  style: _inputLabelStyle,
                ),
                _createStartingAccountInput(),
                const SizedBox(height: 50),
                const Icon(Icons.currency_exchange, size: 50),
                _createRateCalculationWidget(),
                const SizedBox(height: 50),
                Text(
                  getAppLocalizations(context)!.toExchange,
                  style: _inputLabelStyle,
                ),
                _createFinalAccountInput(),
                _createSaveButton(),
                _createCancelButton()
              ],
            ),
          )),
    );
  }
}
