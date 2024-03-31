import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/saving.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/core/providers/saving_provider.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/ui/shared/widgets/styled_button_widget.dart';
import 'package:fundy/ui/shared/widgets/submitted_amount_widget.dart';
import 'package:fundy/ui/shared/widgets/text_input_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:fundy/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingFormArguments {
  final Saving? _saving;
  final Account? _previousAccount;

  SavingFormArguments(this._saving, this._previousAccount);
}

class SavingFormPage extends StatefulWidget {
  final SavingFormArguments data;

  const SavingFormPage({super.key, required this.data});

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

  Account? _previousAccount;
  Saving? _saving;
  Account? _account;

  void _fetchSavingAccount() {
    if (_previousAccount != null) {
      _account = _previousAccount;
      return;
    }
    if (_saving == null) return;
    if (_account != null) return;

    _account = Provider.of<AccountProvider>(context, listen: false)
        .getById(_saving!.accountId);
  }

  void _initializePaidAmountInput() {
    double paidAmount = _saving!.paidAmount;
    if (_paidAmountInputController.text.isEmpty) {
      if (paidAmount == 0) {
        _paidAmountInputController.text = "";
      } else {
        _paidAmountInputController.text = paidAmount.toStringAsFixed(2);
      }
    }
  }

  void _initializeInputs() {
    Saving? saving = _saving;
    if (saving == null) return;
    if (_idInputController.text.isEmpty) {
      _idInputController.text = saving.id;
    }
    if (_amountInputController.text.isEmpty) {
      _amountInputController.text = saving.amount.format();
    }
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
          if (_saving == null || _saving != null && _saving!.id != value) {
            if (Provider.of<SavingProvider>(context, listen: false)
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

  List<Widget> _createAccountInputWidgets() {
    _fetchSavingAccount();
    return [
      Text(
        getAppLocalizations(context)!.account,
        style: _inputLabelStyle,
      ),
      AccountDropdownButtonWidget(
        account: _account,
        onChanged: (account) {
          setState(() {
            _account = account;
          });
        },
        validator: (account) {
          if (account != null) return null;

          return getAppLocalizations(context)!.emptySavingAccount;
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
          if (_saving != null) {
            expenseAmount = _saving!.amount;
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
          if (_account == null) return;

          String id = _idInputController.text;
          double amount = double.parse(_amountInputController.text);
          double paidAmount = _paidAmountInputController.text.isEmpty
              ? 0
              : double.parse(_paidAmountInputController.text);
          if (_saving != null) {
            Saving saving = _saving!;
            saving.id = id;
            saving.accountId = _account!.id;
            saving.amount = amount;
            saving.paidAmount = paidAmount;
            Provider.of<SavingProvider>(context, listen: false).save(saving);
          } else {
            Provider.of<SavingProvider>(context, listen: false)
                .save(Saving(id, _account!.id, amount, paidAmount));
          }
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _createDeleteWidget() {
    if (_saving == null) return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: StyledButtonWidget(
          text: getAppLocalizations(context)!.delete,
          isNegativeButton: true,
          onPressed: () {
            Provider.of<SavingProvider>(context, listen: false)
                .delete(_saving!);
            Navigator.pop(context);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _saving = widget.data._saving;
    _previousAccount = widget.data._previousAccount;

    _initializeInputs();
    return Scaffold(
      appBar: AppBar(
        title: Text(_saving == null
            ? getAppLocalizations(context)!.newSaving
            : _saving!.id),
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