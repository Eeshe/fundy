import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/accout_dropdown_button_widget.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFormPage extends StatefulWidget {
  final Transaction? _transaction;
  Account? _account;

  TransactionFormPage(this._account, this._transaction, {super.key});

  @override
  State<StatefulWidget> createState() => TransactionFormPageState();
}

class TransactionFormPageState extends State<TransactionFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionInputController =
      TextEditingController();
  final TextEditingController _amountInputController = TextEditingController();

  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  DateTime _selectedDate = DateTime.now();

  Future<List<Account>> _fetchAccounts() async {
    return await AccountService().fetchAll();
  }

  @override
  void initState() {
    super.initState();
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
      AccountDropdownButtonWidget(widget._account, (account) {
        setState(() {
          widget._account = account!;
        });
      })
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
          if (RegExp(r'[A-Za-z,]+').hasMatch(value.toString())) {
            return getAppLocalizations(context)!.nonNumberAmount;
          }
          double amount = double.parse(value);
          if (amount < 0) {
            if (widget._transaction != null) {
              amount = amount - widget._transaction!.amount;
            }
            if (widget._account!.balance + amount < 0) {
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
              if (widget._account == null) return;

              String description = _descriptionInputController.text;
              double amount = double.parse(_amountInputController.text);
              Transaction transaction = Transaction(
                  widget._account!.id, description, _selectedDate, amount);
              if (widget._transaction == null) {
                widget._account!.addTransaction(transaction);
              } else {
                widget._account!
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
