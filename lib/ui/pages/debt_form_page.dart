import 'package:finman/core/models/debt.dart';
import 'package:finman/core/models/debt_type.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/submitted_amount_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';

class DebtFormPage extends StatefulWidget {
  final Debt? _debt;

  const DebtFormPage(this._debt, {super.key});

  @override
  State<StatefulWidget> createState() => DebtFormState();
}

class DebtFormState extends State<DebtFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idInputController = TextEditingController();
  final TextEditingController _amountInputController = TextEditingController();
  final TextEditingController _paidAmountInputController =
      TextEditingController();

  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  String? _selectedDebtType;

  void _initializePaidAmountInput() {
    double paidAmount = widget._debt!.paidAmount;
    if (paidAmount == 0) {
      _paidAmountInputController.text = "";
    } else {
      _paidAmountInputController.text = paidAmount.toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    super.initState();
    Debt? debt = widget._debt;
    if (debt == null) return;

    _idInputController.text = debt.id;
    _amountInputController.text = debt.amount.toStringAsFixed(2);
    _initializePaidAmountInput();
  }

  List<Widget> _createDescriptionInputWidgets() {
    return [
      Text(getAppLocalizations(context)!.description, style: _inputLabelStyle),
      TextInputWidget(
          inputController: _idInputController,
          hintText: getAppLocalizations(context)!.debtDescriptionHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return getAppLocalizations(context)!.emptyDebtDescription;
            }
            return null;
          })
    ];
  }

  Row _createDebtTypeRadios() {
    List<Expanded> radios = [];
    for (DebtType debtType in DebtType.values) {
      radios.add(Expanded(
        flex: 1,
        child: Row(
          children: [
            Radio(
                value: debtType.name,
                groupValue: _selectedDebtType,
                onChanged: (value) =>
                    setState(() => _selectedDebtType = value.toString())),
            Text(
              debtType.localized(context),
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ));
    }
    return Row(children: radios);
  }

  List<Widget> _createDebtTypeInputWidgets() {
    return [
      Text(getAppLocalizations(context)!.debtType, style: _inputLabelStyle),
      _createDebtTypeRadios()
    ];
  }

  List<Widget> _createAmountInputsWidgets() {
    return [
      Center(
        child: Text(
          getAppLocalizations(context)!.amount,
          style: _inputLabelStyle,
        ),
      ),
      SubmittedAmountWidget(
        submittedAmountController: _paidAmountInputController,
        submittedAmountHintText: '0.00',
        submittedAmountValidator: (value) {
          if (value != null && !value.isNumeric()) {
            return getAppLocalizations(context)!.nonNumberAmount;
          }
          double submittedDebtAmount;
          if (widget._debt != null) {
            submittedDebtAmount = widget._debt!.amount;
          } else {
            String expenseAmountString = _amountInputController.text;
            if (expenseAmountString.isEmpty ||
                !expenseAmountString.isNumeric()) {
              return getAppLocalizations(context)!.invalidExpenseAmount;
            }
            submittedDebtAmount = double.parse(expenseAmountString);
          }
          double paidAmount = value!.isEmpty ? 0 : double.parse(value);
          if (paidAmount < 0) {
            return getAppLocalizations(context)!.lessThanZeroPaidAmount;
          }
          if (paidAmount > submittedDebtAmount) {
            return getAppLocalizations(context)!
                .paidAmountHigherThanSavingAmount;
          }
          return null;
        },
        totalAmountController: _amountInputController,
        totalAmountHintText: '0.00',
        totalAmountValidator: (value) {
          if (value == null || value.isEmpty) {
            return getAppLocalizations(context)!.emptySavingAmount;
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

  Widget _createConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
        text: getAppLocalizations(context)!.save,
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;

          String id = _idInputController.text;
          DebtType debtType = DebtType.values
              .firstWhere((element) => element.name == _selectedDebtType);
          double amount = double.parse(_amountInputController.text);
          double paidAmount = _paidAmountInputController.text.isEmpty
              ? 0
              : double.parse(_paidAmountInputController.text);
          if (widget._debt != null) {
            Debt debt = widget._debt!;
            debt.id = id;
            debt.debtType = debtType;
            debt.amount = amount;
            debt.paidAmount = paidAmount;
            debt.saveData();
          } else {
            Debt(id, debtType, amount, paidAmount).saveData();
          }
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _createDeleteWidget() {
    if (widget._debt == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
          text: getAppLocalizations(context)!.delete,
          isNegativeButton: true,
          onPressed: () {
            widget._debt!.delete();
            Navigator.pop(context);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedDebtType ??=
        widget._debt == null ? DebtType.own.name : widget._debt!.debtType.name;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._debt == null
            ? getAppLocalizations(context)!.newDebt
            : widget._debt!.id),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
      ),
      body: ScrollablePageWidget(
        padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._createDescriptionInputWidgets(),
              const SizedBox(height: 10),
              ..._createDebtTypeInputWidgets(),
              ..._createAmountInputsWidgets(),
              const SizedBox(height: 10),
              _createConfirmButton(),
              _createDeleteWidget()
            ],
          ),
        ),
      ),
    );
  }
}
