import 'package:finman/core/models/monthly_expense.dart';
import 'package:finman/core/providers/monthly_expense_provider.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/submitted_amount_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class ExpenseFormArguments {
  final MonthlyExpense? _monthlyExpense;
  final DateTime? _selectedDate;

  ExpenseFormArguments(this._monthlyExpense, this._selectedDate);
}

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({super.key});

  @override
  State<StatefulWidget> createState() => ExpenseFormPageState();
}

class ExpenseFormPageState extends State<ExpenseFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idInputController = TextEditingController();
  final TextEditingController _amountInputController = TextEditingController();
  final TextEditingController _paidAmountInputController =
      TextEditingController();
  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  MonthlyExpense? _monthlyExpense;
  DateTime? _selectedDate;

  void _initializePaidAmountInput() {
    if (_monthlyExpense == null) return;

    double paymentRecord = _monthlyExpense!.getPaymentRecord(_selectedDate!);
    if (_paidAmountInputController.text.isEmpty) {
      if (paymentRecord == 0) {
        _paidAmountInputController.text = "";
      } else {
        _paidAmountInputController.text = paymentRecord.format();
      }
    }
  }

  void _initializeInputs() {
    MonthlyExpense? monthlyExpense = _monthlyExpense;
    if (monthlyExpense == null) {
      return;
    }
    if (_idInputController.text.isEmpty) {
      _idInputController.text = monthlyExpense.id;
    }
    if (_amountInputController.text.isEmpty) {
      _amountInputController.text = monthlyExpense.amount.format();
    }
    _initializePaidAmountInput();
  }

  Widget _createDescriptionInputWidget() {
    String locale = Localizations.localeOf(context).languageCode;
    String buttonText =
        "${DateFormat.MMMM(locale).format(_selectedDate!).capitalize()} ${_selectedDate!.year}";
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getAppLocalizations(context)!.description,
              style: _inputLabelStyle,
            ),
            StyledButtonWidget(
              padding: const EdgeInsets.all(10),
              text: buttonText,
              onPressed: () async {
                DateTime? pickedDate = await showMonthPicker(
                  selectedMonthTextColor:
                      Theme.of(context).colorScheme.onBackground,
                  selectedMonthBackgroundColor:
                      Theme.of(context).colorScheme.primary,
                  currentMonthTextColor:
                      Theme.of(context).colorScheme.onBackground,
                  context: context,
                  initialDate: _selectedDate,
                );
                if (pickedDate == null) return;

                setState(
                  () {
                    _selectedDate = pickedDate;
                  },
                );
              },
            ),
          ],
        ),
        TextInputWidget(
          inputController: _idInputController,
          hintText: getAppLocalizations(context)!.transactionDescriptionHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return getAppLocalizations(context)!.emptyExpenseName;
            }
            return null;
          },
        )
      ],
    );
  }

  List<Widget> _createAmountInputsWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.amount,
        style: _inputLabelStyle,
      ),
      SubmittedAmountWidget(
        submittedAmountController: _paidAmountInputController,
        submittedAmountHintText: '0.00',
        submittedAmountValidator: (value) {
          if (value != null && !value.isNumeric()) {
            return getAppLocalizations(context)!.nonNumberAmount;
          }
          double expenseAmount;
            String expenseAmountString = _amountInputController.text;
            if (expenseAmountString.isEmpty ||
                !expenseAmountString.isNumeric()) {
              return getAppLocalizations(context)!.invalidExpenseAmount;
          }
          expenseAmount = double.parse(expenseAmountString);
          double paidAmount = value!.isEmpty ? 0 : double.parse(value);
          if (paidAmount < 0) {
            return getAppLocalizations(context)!.lessThanZeroPaidAmount;
          }
          if (paidAmount > expenseAmount) {
            return getAppLocalizations(context)!
                .paidAmountHigherThanExpenseAmount;
          }
          return null;
        },
        totalAmountController: _amountInputController,
        totalAmountHintText: '0.00',
        totalAmountValidator: (value) {
          if (value == null || value.isEmpty) {
            return getAppLocalizations(context)!.emptyExpenseAmount;
          }
          if (!value.isNumeric()) {
            return getAppLocalizations(context)!.nonNumberAmount;
          }
          if (double.parse(value) <= 0) {
            return getAppLocalizations(context)!.lessThanZeroAmount;
          }
          return null;
        },
      )
    ];
  }

  Widget _createSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
        text: getAppLocalizations(context)!.save,
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          String id = _idInputController.text;
          double amount = double.parse(_amountInputController.text);
          double paidAmount = _paidAmountInputController.text.isEmpty
              ? 0
              : double.parse(_paidAmountInputController.text);
          if (_monthlyExpense != null) {
            MonthlyExpense monthlyExpense = _monthlyExpense!;
            monthlyExpense.id = id;
            monthlyExpense.amount = amount;
            monthlyExpense.paymentRecords[
                MonthlyExpense.createRecordKey(_selectedDate!)] = paidAmount;
            Provider.of<MonthlyExpenseProvider>(context, listen: false)
                .save(monthlyExpense);
          } else {
            Map<String, double> paymentRecords = {
              MonthlyExpense.createRecordKey(_selectedDate!): paidAmount
            };
            Provider.of<MonthlyExpenseProvider>(context, listen: false).save(
                MonthlyExpense(id, amount, DateTime.now(), paymentRecords));
          }
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _createDeleteWidget() {
    if (_monthlyExpense == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
        text: getAppLocalizations(context)!.delete,
        isNegativeButton: true,
        onPressed: () {
          Provider.of<MonthlyExpenseProvider>(context, listen: false)
              .delete(_monthlyExpense!);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ExpenseFormArguments expenseFormArguments =
        ModalRoute.of(context)!.settings.arguments as ExpenseFormArguments;
    _monthlyExpense = expenseFormArguments._monthlyExpense;
    _selectedDate ??= expenseFormArguments._selectedDate;

    _initializeInputs();
    return Scaffold(
      appBar: AppBar(
        title: Text(_monthlyExpense != null
            ? _monthlyExpense!.id
            : getAppLocalizations(context)!.newExpense),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      resizeToAvoidBottomInset: false,
      body: ScrollablePageWidget(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _createDescriptionInputWidget(),
              const SizedBox(height: 20),
              ..._createAmountInputsWidgets(),
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
