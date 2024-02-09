import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/accout_dropdown_button_widget.dart';
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

  Widget createDeleteWidget() {
    if (widget._transaction == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget._account!.deleteTransaction(widget._transaction!);
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
        title: Text(widget._transaction == null
            ? getAppLocalizations(context)!.newTransaction
            : getAppLocalizations(context)!.editTransaction),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getAppLocalizations(context)!.account,
                    style: _inputLabelStyle,
                  ),
                  AccountDropdownButtonWidget(widget._account, (account) {
                    setState(() {
                      widget._account = account!;
                    });
                  }),
                  Text(
                    getAppLocalizations(context)!.description,
                    style: _inputLabelStyle,
                  ),
                  TextFormField(
                    controller: _descriptionInputController,
                    decoration: InputDecoration(
                      hintText: getAppLocalizations(context)!
                          .transactionDescriptionHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return getAppLocalizations(context)!
                            .emptyTransactionDescription;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    getAppLocalizations(context)!.date,
                    style: _inputLabelStyle,
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy - kk:mm').format(_selectedDate),
                        style: _inputLabelStyle,
                      ),
                      const SizedBox(
                        width: 10,
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
                              initialTime:
                                  TimeOfDay.fromDateTime(_selectedDate));
                          if (pickedTime == null) return;

                          setState(() {
                            _selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute);
                          });
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    getAppLocalizations(context)!.amount,
                    style: _inputLabelStyle,
                  ),
                  TextFormField(
                    controller: _amountInputController,
                    decoration: const InputDecoration(
                      hintText: '0.00',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return getAppLocalizations(context)!
                            .emptyTransactionAmount;
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
                          return getAppLocalizations(context)!
                              .negativeBalanceAmount;
                        }
                      }
                      return null;
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) return;
                                if (widget._account == null) return;

                                String description =
                                    _descriptionInputController.text;
                                double amount =
                                    double.parse(_amountInputController.text);
                                Transaction transaction = Transaction(
                                    widget._account!.id,
                                    description,
                                    _selectedDate,
                                    amount);
                                if (widget._transaction == null) {
                                  widget._account!.addTransaction(transaction);
                                } else {
                                  widget._account!.updateTransaction(
                                      widget._transaction!, transaction);
                                }
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.pop(context);
                              },
                              child: Text(getAppLocalizations(context)!.save)))
                    ],
                  ),
                  createDeleteWidget()
                ],
              ),
            )),
      ),
    );
  }
}
