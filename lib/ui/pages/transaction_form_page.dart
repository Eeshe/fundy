import 'dart:math';

import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFormPage extends StatefulWidget {
  final Transaction? _transaction;
  final Account? _account;

  const TransactionFormPage(this._account, this._transaction, {super.key});

  @override
  State<StatefulWidget> createState() => TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionInputController =
      TextEditingController();
  final TextEditingController _amountInputController = TextEditingController();

  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  Account? _selectedAccount;
  bool _isMobilePayment = false;
  DateTime _selectedDate = DateTime.now();

  Future<List<Account>> _fetchAccounts() async {
    return await AccountService().fetchAll();
  }

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget._account;
    _fetchAccounts();

    Transaction? transaction = widget._transaction;
    if (transaction == null) return;

    _descriptionInputController.text = transaction.description;
    _amountInputController.text = transaction.amount.toStringAsFixed(2);
    _selectedDate = transaction.date;
  }

  List<Widget> _createAccountInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.account,
        style: _inputLabelStyle,
      ),
      AccountDropdownButtonWidget(
        account: widget._account,
        onChanged: widget._account != null
            ? null
            : (account) {
                setState(
                  () {
                    _selectedAccount = account!;
                    if (account.currencyType == CurrencyType.bs) return;

                    _isMobilePayment = false;
                  },
                );
              },
      )
    ];
  }

  List<Widget> _createMobilePaymentInputWidgets() {
    if (_selectedAccount == null ||
        _selectedAccount!.currencyType != CurrencyType.bs) {
      return [];
    }
    if (widget._transaction != null) {
      _isMobilePayment = widget._transaction!.isMobilePayment;
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
            DateFormat('dd/MM/yyyy - kk:mm').format(_selectedDate),
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
                  initialTime: TimeOfDay.fromDateTime(_selectedDate));
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
            if (widget._transaction != null) {
              amount = amount - widget._transaction!.amount;
            }
            if (_selectedAccount!.balance + amount < 0) {
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
              if (_selectedAccount == null) return;

              String description = _descriptionInputController.text;
              double amount = double.parse(_amountInputController.text);
              if (_isMobilePayment &&
                  (widget._transaction == null ||
                      !widget._transaction!.isMobilePayment)) {
                amount += _calculateMobilePaymentFee(amount);
              }
              Transaction transaction = Transaction(_selectedAccount!.id,
                  description, _selectedDate, amount, _isMobilePayment);
              if (widget._transaction == null) {
                _selectedAccount!.addTransaction(transaction);
              } else {
                _selectedAccount!
                    .updateTransaction(widget._transaction!, transaction);
              }
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  Widget _createDeleteWidget() {
    if (widget._transaction == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
            child: StyledButtonWidget(
                text: getAppLocalizations(context)!.delete,
                isNegativeButton: true,
                onPressed: () {
                  widget._account!.deleteTransaction(widget._transaction!);
                  Navigator.pop(context);
                }))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._transaction == null
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
