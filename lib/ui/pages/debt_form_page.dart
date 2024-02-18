import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/debt.dart';
import 'package:finman/core/models/debt_type.dart';
import 'package:finman/core/models/saving.dart';
import 'package:finman/ui/shared/localization.dart';
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

  String _selectedDebtType = DebtType.own.toString();

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

  Widget _createDescriptionInputWidget() {
    return TextFormField(
      controller: _idInputController,
      decoration: InputDecoration(
        hintText: getAppLocalizations(context)!.debtDescriptionHint,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return getAppLocalizations(context)!.emptyDebtDescription;
        }
        return null;
      },
    );
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

  Widget _createPaidAmountInputWidget() {
    return TextFormField(
      controller: _paidAmountInputController,
      decoration: const InputDecoration(
        hintText: '0.00',
      ),
      validator: (value) {
        if (value != null && !value.isNumeric()) {
          return getAppLocalizations(context)!.nonNumberAmount;
        }
        double expenseAmount;
        if (widget._debt != null) {
          expenseAmount = widget._debt!.amount;
        } else {
          String expenseAmountString = _amountInputController.text;
          if (expenseAmountString.isEmpty || !expenseAmountString.isNumeric()) {
            return getAppLocalizations(context)!.invalidDebtAmount;
          }
          expenseAmount = double.parse(expenseAmountString);
        }
        double paidAmount = value!.isEmpty ? 0 : double.parse(value);
        if (paidAmount < 0) {
          return getAppLocalizations(context)!.lessThanZeroPaidAmount;
        }
        if (paidAmount > expenseAmount) {
          return getAppLocalizations(context)!.paidAmountHigherThanDebtAmount;
        }
        return null;
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _createAmountInputWidget() {
    return TextFormField(
      controller: _amountInputController,
      decoration: const InputDecoration(
        hintText: '0.00',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return getAppLocalizations(context)!.emptyDebtAmount;
        }
        if (RegExp(r'[A-Za-z,]+').hasMatch(value.toString())) {
          return getAppLocalizations(context)!.nonNumberAmount;
        }
        if (double.parse(value) <= 0) {
          return getAppLocalizations(context)!.lessThanZeroAmount;
        }
        return null;
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _createAmountsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: _createPaidAmountInputWidget()),
        const Expanded(
            flex: 1,
            child: Text(
              "/",
              style: TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            )),
        Expanded(flex: 5, child: _createAmountInputWidget())
      ],
    );
  }

  Widget _createConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
          child: Text(getAppLocalizations(context)!.save)),
    );
  }

  Widget _createDeleteWidget() {
    if (widget._debt == null) return const SizedBox();
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget._debt!.delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(getAppLocalizations(context)!.delete),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._debt == null
            ? getAppLocalizations(context)!.newDebt
            : widget._debt!.id),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getAppLocalizations(context)!.description,
                    style: _inputLabelStyle),
                _createDescriptionInputWidget(),
                Text(getAppLocalizations(context)!.debtType,
                    style: _inputLabelStyle),
                _createDebtTypeRadios(),
                Center(
                    child: Text(getAppLocalizations(context)!.amount,
                        style: _inputLabelStyle)),
                _createAmountsWidget(),
                _createConfirmButton(),
                _createDeleteWidget()
              ],
            )),
      ),
    );
  }
}
