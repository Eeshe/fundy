import 'dart:math';

import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/currency_type.dart';
import 'package:fundy/core/models/transaction.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/ui/shared/widgets/styled_button_widget.dart';
import 'package:fundy/ui/shared/widgets/text_input_widget.dart';
import 'package:fundy/utils/date_time_extension.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:fundy/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionFormArguments {
  final Transaction? _transaction;
  final Account? _account;

  TransactionFormArguments(this._transaction, this._account);
}

class TransactionFormPage extends StatefulWidget {
  final TransactionFormArguments data;

  const TransactionFormPage({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionInputController =
      TextEditingController();
  final TextEditingController _amountInputController = TextEditingController();

  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  bool _isMobilePayment = false;

  Transaction? _transaction;
  Account? _account;
  DateTime? _selectedDate;

  void _initializeInputs() {
    Transaction? transaction = _transaction;
    if (transaction == null) {
      _selectedDate ??= DateTime.now();
      return;
    }
    if (_descriptionInputController.text.isEmpty) {
      _descriptionInputController.text = transaction.description;
    }
    if (_amountInputController.text.isEmpty) {
      _amountInputController.text = transaction.amount.format();
    }
    _selectedDate ??= transaction.date;
  }

  List<Widget> _createAccountInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.account,
        style: _inputLabelStyle,
      ),
      AccountDropdownButtonWidget(
        account: _account,
        onChanged: widget.data._account != null
            ? null
            : (account) {
                setState(
                  () {
                    _account = account!;
                    if (account.currencyType == CurrencyType.bs) return;

                    _isMobilePayment = false;
                  },
                );
              },
      )
    ];
  }

  List<Widget> _createMobilePaymentInputWidgets() {
    if (_account == null || _account!.currencyType != CurrencyType.bs) {
      return [];
    }
    if (_transaction != null) {
      _isMobilePayment = _transaction!.isMobilePayment;
    }
    return [
      Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: _isMobilePayment,
              onChanged: (value) {
                setState(() {
                  _isMobilePayment = !_isMobilePayment;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Text(getAppLocalizations(context)!.mobilePayment)
        ],
      ),
      const SizedBox(height: 10)
    ];
  }

  List<Widget> _createDescriptionInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.description,
        style: _inputLabelStyle,
      ),
      TextInputWidget(
        inputController: _descriptionInputController,
        hintText: getAppLocalizations(context)!.transactionDescriptionHint,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return getAppLocalizations(context)!.emptyTransactionDescription;
          }
          return null;
        },
      )
    ];
  }

  List<Widget> _createDateInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.date,
        style: _inputLabelStyle,
      ),
      Row(
        children: [
          Text(
            _selectedDate!.formatDayMonthYearTime(),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (pickedDate == null) return;
              if (!context.mounted) return;
              TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDate!));
              if (pickedTime == null) return;

              setState(() {
                _selectedDate = DateTime(pickedDate.year, pickedDate.month,
                    pickedDate.day, pickedTime.hour, pickedTime.minute);
              });
            },
            icon: Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      )
    ];
  }

  double _calculateMobilePaymentFee(double amount) {
    return min(-0.13, amount * 0.003);
  }

  List<Widget> _createAmountInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.amount,
        style: _inputLabelStyle,
      ),
      TextInputWidget(
        inputController: _amountInputController,
        hintText: '0.00',
        textInputType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return getAppLocalizations(context)!.emptyTransactionAmount;
          }
          if (!value.isNumeric()) {
            return getAppLocalizations(context)!.nonNumberAmount;
          }
          double amount = double.parse(value);
          if (_isMobilePayment) {
            if (amount > 0) {
              return getAppLocalizations(context)!.positiveMobilePayment;
            }
            amount -= _calculateMobilePaymentFee(amount);
          }
          if (amount < 0) {
            if (_transaction != null) {
              amount = amount - _transaction!.amount;
            }
            if (_account!.balance + amount < 0) {
              return getAppLocalizations(context)!.negativeBalanceAmount;
            }
          }
          return null;
        },
      )
    ];
  }

  Widget _createSaveButton() {
    return Row(
      children: [
        Expanded(
          child: StyledButtonWidget(
            text: getAppLocalizations(context)!.save,
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              if (_account == null) return;

              String description = _descriptionInputController.text;
              double amount = double.parse(_amountInputController.text);
              if (_isMobilePayment &&
                  (_transaction == null || !_transaction!.isMobilePayment)) {
                amount += _calculateMobilePaymentFee(amount);
              }
              Transaction transaction = Transaction(_account!.id, description,
                  _selectedDate!, amount, _isMobilePayment);
              if (_transaction == null) {
                _account!.addTransaction(transaction);
              } else {
                _account!.updateTransaction(_transaction!, transaction);
              }
              Provider.of<AccountProvider>(context, listen: false)
                  .save(_account!);
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  Widget _createDeleteWidget() {
    if (_transaction == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
            child: StyledButtonWidget(
                text: getAppLocalizations(context)!.delete,
                isNegativeButton: true,
                onPressed: () {
                  _account!.deleteTransaction(_transaction!);
                  Provider.of<AccountProvider>(context, listen: false)
                      .save(_account!);
                  Navigator.pop(context);
                }))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _transaction = widget.data._transaction;
    _account ??= widget.data._account;
    _initializeInputs();
    return Scaffold(
      appBar: AppBar(
        title: Text(_transaction == null
            ? getAppLocalizations(context)!.newTransaction
            : getAppLocalizations(context)!.editTransaction),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ScrollablePageWidget(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._createAccountInputWidgets(),
              const SizedBox(height: 10),
              ..._createMobilePaymentInputWidgets(),
              ..._createDescriptionInputWidgets(),
              const SizedBox(height: 20),
              ..._createDateInputWidgets(),
              ..._createAmountInputWidgets(),
              const SizedBox(height: 10),
              _createSaveButton(),
              _createDeleteWidget()
            ],
          ),
        ),
      ),
    );
  }
}
