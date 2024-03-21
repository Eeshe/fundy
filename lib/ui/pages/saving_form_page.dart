import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/saving.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/submitted_amount_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';

class SavingFormPage extends StatefulWidget {
  final Saving? _saving;
  final Account? _account;

  const SavingFormPage(this._saving, this._account, {super.key});

  @override
  State<StatefulWidget> createState() => SavingFormState();
}

class SavingFormState extends State<SavingFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idInputController = TextEditingController();
  final TextEditingController _amountInputController = TextEditingController();
  final TextEditingController _paidAmountInputController =
      TextEditingController();

  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  Account? _selectedAccount;

  Future<void> _fetchSavingAccount() async {
    if (widget._account != null) {
      _selectedAccount = widget._account;
      return;
    }
    if (widget._saving == null) return;
    if (_selectedAccount != null) return;

    _selectedAccount = await AccountService().fetch(widget._saving!.accountId);
  }

  void _initializePaidAmountInput() {
    double paidAmount = widget._saving!.paidAmount;
    if (paidAmount == 0) {
      _paidAmountInputController.text = "";
    } else {
      _paidAmountInputController.text = paidAmount.toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    super.initState();
    Saving? saving = widget._saving;
    if (saving == null) return;

    _idInputController.text = saving.id;
    _amountInputController.text = saving.amount.toStringAsFixed(2);
    _initializePaidAmountInput();
  }

  List<Widget> _createDescriptionInputWidgets() {
    return [
      Text(getAppLocalizations(context)!.description, style: _inputLabelStyle),
      TextInputWidget(
        inputController: _idInputController,
        hintText: getAppLocalizations(context)!.savingDescriptionHint,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return getAppLocalizations(context)!.emptySavingDescription;
          }
          return null;
        },
      )
    ];
  }

  List<Widget> _createAccountInputWidgets() {
    return [
      Text(
        getAppLocalizations(context)!.account,
        style: _inputLabelStyle,
      ),
      FutureBuilder(
        future: _fetchSavingAccount(),
        builder: (context, snapshot) {
          return AccountDropdownButtonWidget(
            _selectedAccount,
            (account) {
              setState(() {
                _selectedAccount = account;
              });
            },
          );
        },
      )
    ];
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
          if (widget._saving != null) {
            expenseAmount = widget._saving!.amount;
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
          if (_selectedAccount == null) return;

          String id = _idInputController.text;
          double amount = double.parse(_amountInputController.text);
          double paidAmount = _paidAmountInputController.text.isEmpty
              ? 0
              : double.parse(_paidAmountInputController.text);
          if (widget._saving != null) {
            Saving saving = widget._saving!;
            saving.id = id;
            saving.accountId = _selectedAccount!.id;
            saving.amount = amount;
            saving.paidAmount = paidAmount;
            saving.saveData();
          } else {
            Saving(id, _selectedAccount!.id, amount, paidAmount).saveData();
          }
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _createDeleteWidget() {
    if (widget._saving == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
          text: getAppLocalizations(context)!.delete,
          isNegativeButton: true,
          onPressed: () {
            widget._saving!.delete();
            Navigator.pop(context);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._saving == null
            ? getAppLocalizations(context)!.newSaving
            : widget._saving!.id),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
      ),
      body: ScrollablePageWidget(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._createDescriptionInputWidgets(),
              const SizedBox(height: 10),
              ..._createAccountInputWidgets(),
              const SizedBox(height: 10),
              Center(
                  child: Text(getAppLocalizations(context)!.amount,
                      style: _inputLabelStyle)),
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
