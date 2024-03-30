import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/providers/account_provider.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExchangeFormPage extends StatefulWidget {
  const ExchangeFormPage({super.key});

  @override
  State<StatefulWidget> createState() => ExchangeFormPageState();
}

class ExchangeFormPageState extends State<ExchangeFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _startingAmountController =
      TextEditingController();
  final TextEditingController _finalAmountController = TextEditingController();

  Account? _startingAccount;
  Account? _finalAccount;

  Widget _createStartingAccountInputWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: AccountDropdownButtonWidget(
          account: _startingAccount,
          onChanged: (account) {
            setState(() {
              _startingAccount = account;
            });
          },
          validator: (value) {
            if (value != _finalAccount) return null;

            return getAppLocalizations(context)!.sameAccountExchange;
          },
        )),
        const SizedBox(width: 20),
        Flexible(
          child: TextInputWidget(
            inputController: _startingAmountController,
            hintText: '0.00',
            textInputType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (_startingAccount == null) {
                return getAppLocalizations(context)!.emptyStartingAccount;
              }
              if (value == null || value.isEmpty) {
                return getAppLocalizations(context)!.emptyExchangeAmount;
              }
              if (!value.isNumeric()) {
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
            onChanged: (p0) {
              setState(() {});
              return null;
            },
          ),
        )
      ],
    );
  }

  Widget _createRateCalculationWidget() {
    String startingAmountString = _startingAmountController.text;
    String finalAmountString = _finalAmountController.text;
    double rate;
    if (startingAmountString.isEmpty ||
        finalAmountString.isEmpty ||
        !startingAmountString.isNumeric() ||
        !finalAmountString.isNumeric()) {
      rate = 0;
    } else {
      double startingAmount = double.parse(startingAmountString);
      double finalAmount = double.parse(finalAmountString);
      rate = finalAmount / startingAmount;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          Icons.arrow_downward,
          size: 25,
          color: Theme.of(context).colorScheme.primary,
        ),
        Flexible(
          child: Text(
            rate.format(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        Icon(
          Icons.arrow_downward,
          size: 25,
          color: Theme.of(context).colorScheme.primary,
        )
      ],
    );
  }

  Widget _createFinalAccountInput() {
    return Row(
      children: [
        Flexible(
            child: AccountDropdownButtonWidget(
          account: _finalAccount,
          onChanged: (account) {
            setState(() {
              _finalAccount = account;
            });
          },
          validator: (value) {
            if (value != _startingAccount) return null;

            return getAppLocalizations(context)!.sameAccountExchange;
          },
        )),
        const SizedBox(width: 20),
        Flexible(
          child: TextInputWidget(
            inputController: _finalAmountController,
            hintText: '0.00',
            textInputType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (_finalAccount == null) {
                return getAppLocalizations(context)!.emptyFinalAccount;
              }
              if (value == null || value.isEmpty) {
                return getAppLocalizations(context)!.emptyExchangeAmount;
              }
              if (!value.isNumeric()) {
                return getAppLocalizations(context)!.nonNumberAmount;
              }
              double amount = double.parse(value);
              if (amount < 0) {
                return getAppLocalizations(context)!.negativeBalanceAmount;
              }
              return null;
            },
            onChanged: (p0) {
              setState(() {});
              return null;
            },
          ),
        )
      ],
    );
  }

  Widget _createSaveButton() {
    return Row(
      children: [
        Expanded(
          child: StyledButtonWidget(
            text: getAppLocalizations(context)!.save,
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              if (_startingAccount == _finalAccount) return;

              double startingAmount =
                  double.parse(_startingAmountController.text);
              double finalAmount = double.parse(_finalAmountController.text);

              _startingAccount!.addTransaction(Transaction(
                  _startingAccount!.id,
                  getAppLocalizations(context)!.exchangeDescription(
                      _startingAccount!.id, _finalAccount!.id),
                      DateTime.now(),
                  -startingAmount,
                  false));
              Provider.of<AccountProvider>(context, listen: false)
                  .save(_startingAccount!);
              _finalAccount!.addTransaction(Transaction(
                      _finalAccount!.id,
                      getAppLocalizations(context)!.exchangeDescription(
                          _startingAccount!.id, _finalAccount!.id),
                      DateTime.now(),
                  finalAmount,
                  false));
              Provider.of<AccountProvider>(context, listen: false)
                  .save(_finalAccount!);

              FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  Widget _createCancelButton() {
    return Row(
      children: [
        Expanded(
          child: StyledButtonWidget(
            text: getAppLocalizations(context)!.cancel,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getAppLocalizations(context)!.exchange),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      resizeToAvoidBottomInset: false,
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _createStartingAccountInputWidgets(),
                const SizedBox(height: 20),
                _createRateCalculationWidget(),
                const SizedBox(height: 20),
                _createFinalAccountInput(),
                const SizedBox(height: 10),
                _createSaveButton(),
                _createCancelButton()
              ],
            ),
          )),
    );
  }
}
