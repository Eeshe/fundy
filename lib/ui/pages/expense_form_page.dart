import 'package:finman/core/models/monthly_expense.dart';
import 'package:finman/core/services/monthly_expense_service.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/submitted_amount_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class ExpenseFormPage extends StatefulWidget {
  final MonthlyExpense? _monthlyExpense;
  DateTime _selectedDate;

  ExpenseFormPage(this._monthlyExpense, this._selectedDate, {super.key});

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

  void _initializePaidAmountInput() {
    if (widget._monthlyExpense == null) return;

    double paymentRecord =
        widget._monthlyExpense!.getPaymentRecord(widget._selectedDate);
    if (paymentRecord == 0) {
      _paidAmountInputController.text = "";
    } else {
      _paidAmountInputController.text = paymentRecord.toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    super.initState();
    MonthlyExpense? monthlyExpense = widget._monthlyExpense;
    if (monthlyExpense == null) return;

    _idInputController.text = monthlyExpense.id;
    _amountInputController.text = monthlyExpense.amount.toStringAsFixed(2);
    _initializePaidAmountInput();
  }

  Widget _createDescriptionInputWidget() {
    String locale = Localizations.localeOf(context).languageCode;
    String buttonText =
        "${DateFormat.MMMM(locale).format(widget._selectedDate).capitalize()} ${widget._selectedDate.year}";
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
                  context: context,
                  initialDate: widget._selectedDate,
                );
                if (pickedDate == null) return;

                setState(
                  () {
                    widget._selectedDate = pickedDate;
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
          if (widget._monthlyExpense != null) {
            expenseAmount = widget._monthlyExpense!.amount;
          } else {
            String expenseAmountString = _amountInputController.text;
            if (expenseAmountString.isEmpty ||
                !expenseAmountString.isNumeric()) {
              return getAppLocalizations(context)!.invalidExpenseAmount;
            }
            expenseAmount = double.parse(expenseAmountString);
          }
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
          if (RegExp(r'[A-Za-z,]+').hasMatch(value.toString())) {
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
          if (widget._monthlyExpense != null) {
            MonthlyExpense monthlyExpense = widget._monthlyExpense!;
            monthlyExpense.id = id;
            monthlyExpense.amount = amount;
            monthlyExpense.paymentRecords[
                    MonthlyExpense.createRecordKey(widget._selectedDate)] =
                paidAmount;
            monthlyExpense.saveData();
          } else {
            Map<String, double> paymentRecords = {
              MonthlyExpense.createRecordKey(widget._selectedDate): paidAmount
            };
            MonthlyExpenseService().save(
                MonthlyExpense(id, amount, DateTime.now(), paymentRecords));
          }
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _createDeleteWidget() {
    if (widget._monthlyExpense == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
        text: getAppLocalizations(context)!.delete,
        isNegativeButton: true,
        onPressed: () {
          widget._monthlyExpense!.delete();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializePaidAmountInput();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._monthlyExpense != null
            ? widget._monthlyExpense!.id
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
