import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/currency_type.dart';
import 'package:fundy/core/models/debt.dart';
import 'package:fundy/core/models/debt_type.dart';
import 'package:fundy/core/models/monthly_expense.dart';
import 'package:fundy/core/models/transaction.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/core/services/conversion_service.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/ui/shared/widgets/styled_button_widget.dart';
import 'package:fundy/ui/shared/widgets/text_input_widget.dart';
import 'package:fundy/utils/date_time_extension.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:fundy/utils/string_extension.dart';
import 'package:provider/provider.dart';

import '../../core/models/contributable.dart';
import '../../core/providers/debt_provider.dart';
import '../../core/providers/monthly_expense_provider.dart';

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
  Contributable1? _contributable;

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

  Widget _createContributionListWidget() {
    return Consumer2<MonthlyExpenseProvider, DebtProvider>(
      builder: (context, monthlyExpenseProvider, debtProvider, child) {
        List<Contributable1> contributables = [];
        for (var monthlyExpense in monthlyExpenseProvider.monthlyExpenses) {
          contributables.add(monthlyExpense.toContributable(_selectedDate!));
        }
        for (var debt in debtProvider.debts) {
          contributables.add(debt.toContributable());
        }
        contributables.sort((a, b) => a.id.compareTo(b.id));
        return ListView.separated(
          itemCount: contributables.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            Contributable1 contributable = contributables[index];
            return contributable.createListWidget(
              context,
              contributable.id == _contributable?.id,
              () => setState(() {
                if (_contributable?.id == contributable.id) {
                  _contributable = null;
                } else {
                  _contributable = contributable;
                }
              }),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 5),
        );
      },
    );
  }

  List<Widget> _createContributionWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.contributesTo,
        style: _inputLabelStyle,
      ),
      SizedBox(
        height: 100,
        child: _createContributionListWidget(),
      )
    ];
  }

  void _handleContribution(double amount) {
    if (_contributable == null) return;

    double amountUsd = ConversionService.getInstance()
        .currencyToUsd(amount, _account!.currencyType.name);
    if (_contributable!.debtType == null) {
      MonthlyExpenseProvider monthlyExpenseProvider =
          Provider.of<MonthlyExpenseProvider>(context, listen: false);
      MonthlyExpense? monthlyExpense =
          monthlyExpenseProvider.getById(_contributable!.id);
      if (monthlyExpense == null) return;

      monthlyExpense.addPayment(_selectedDate!, amountUsd);
      monthlyExpenseProvider.save(monthlyExpense);
    } else {
      DebtProvider debtProvider =
          Provider.of<DebtProvider>(context, listen: false);
      Debt? debt = debtProvider.getById(_contributable!.id);
      if (debt == null) return;

      double remainingAmount = debt.calculateRemainingAmount();
      double excess = amountUsd.abs() - remainingAmount;
      DebtType debtType = debt.debtType;
      if (debtType == DebtType.own) {
        if (amountUsd > 0) {
          // User is increasing its own debt, as they are receiving money
          print("INCREASING USER DEBT");
        } else {
          print("DECREASING USER DEBT");
          // User is reducing its own debt, as they are giving money
        }
      } else {
        if (amountUsd > 0) {
          // Third party is reducing their debt, as the user is receiving money
          print("DECREASING THIRD PARTY DEBT");
        } else {
          // Third party is increasing their debt, as the user is giving money
          print("INCREASING THIRD PARTY DEBT");
        }
      }
      // if (excess == 0) {
      //   debt.increasePaidAmount(amountUsd);
      // } else {
      //   if (excess > 0) {
      //     // Amount exceeds the remaining amount positively
      //     // This means the debt is overpaid and the debt type is reversed
      //     debt.debtType =
      //         debt.debtType == DebtType.own ? DebtType.other : DebtType.own;
      //     debt.amount = excess;
      //     debt.paidAmount = 0;
      //   }
      // }
      // debtProvider.save(debt);
    }
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
              _handleContribution(amount);

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
      resizeToAvoidBottomInset: true,
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
              ..._createContributionWidgets(),
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
