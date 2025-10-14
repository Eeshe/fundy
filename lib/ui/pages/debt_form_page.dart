import 'package:fundy/core/models/debt.dart';
import 'package:fundy/core/models/debt_type.dart';
import 'package:fundy/core/providers/debt_provider.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/ui/shared/widgets/styled_button_widget.dart';
import 'package:fundy/ui/shared/widgets/submitted_amount_widget.dart';
import 'package:fundy/ui/shared/widgets/text_input_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:fundy/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebtFormArguments {
  final Debt? _debt;

  DebtFormArguments(this._debt);
}

class DebtFormPage extends StatefulWidget {
  final DebtFormArguments data;

  const DebtFormPage({super.key, required this.data});

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

  Debt? _debt;
  String? _selectedDebtType;

  void _initializePaidAmountInput() {
    double paidAmount = _debt!.paidAmount;
    if (_paidAmountInputController.text.isEmpty) {
      if (paidAmount == 0) {
        _paidAmountInputController.text = "";
      } else {
        _paidAmountInputController.text = paidAmount.format();
      }
    }
  }

  void _initializeInputs() {
    Debt? debt = _debt;
    if (debt == null) return;
    if (_idInputController.text.isEmpty) {
      _idInputController.text = debt.id;
    }
    if (_amountInputController.text.isEmpty) {
      _amountInputController.text = debt.amount.format();
    }
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
          if (_debt == null || _debt != null && _debt!.id != value) {
            if (Provider.of<DebtProvider>(context, listen: false)
                    .getById(value) !=
                null) {
              return getAppLocalizations(context)!.usedSavingDescription;
            }
          }
          return null;
        },
      )
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
          if (_debt != null) {
            submittedDebtAmount = _debt!.amount;
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
          if (_debt != null) {
            Debt debt = _debt!;
            debt.id = id;
            debt.debtType = debtType;
            debt.amount = amount;
            debt.paidAmount = paidAmount;
            Provider.of<DebtProvider>(context, listen: false).save(debt);
          } else {
            Provider.of<DebtProvider>(context, listen: false)
                .save(Debt(id, debtType, amount, paidAmount));
          }
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _createDeleteWidget() {
    if (_debt == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
          text: getAppLocalizations(context)!.delete,
          isNegativeButton: true,
          onPressed: () {
            Provider.of<DebtProvider>(context, listen: false)
                .delete(context, _debt!);
            Navigator.pop(context);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _debt = widget.data._debt;

    _initializeInputs();
    _selectedDebtType ??=
        _debt == null ? DebtType.own.name : _debt!.debtType.name;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _debt == null ? getAppLocalizations(context)!.newDebt : _debt!.id),
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
