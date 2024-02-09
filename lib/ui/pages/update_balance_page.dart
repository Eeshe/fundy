import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:flutter/material.dart';

class UpdateBalancePage extends StatefulWidget {
  final Account _account;

  const UpdateBalancePage(this._account, {super.key});

  @override
  State<StatefulWidget> createState() => UpdateBalancePageStage();
}

class UpdateBalancePageStage extends State<UpdateBalancePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newBalanceInputController =
      TextEditingController();

  final TextStyle _inputLabelStyle = const TextStyle(fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: AccountIconWidget(widget._account.iconPath, 100, 100),
              ),
              Text(
                getAppLocalizations(context)!.newBalance,
                style: _inputLabelStyle,
              ),
              TextFormField(
                controller: _newBalanceInputController,
                decoration: InputDecoration(
                    hintText: widget._account.balance.toString()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return getAppLocalizations(context)!.emptyNewBalance;
                  }
                  if (RegExp(r'[A-Za-z,]+').hasMatch(value.toString())) {
                    return getAppLocalizations(context)!.nonNumberAmount;
                  }
                  if (double.parse(value) < 0) {
                    return getAppLocalizations(context)!.lessThanZeroNewBalance;
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

                      String description =
                          getAppLocalizations(context)!.balanceUpdate;
                      double amount =
                          double.parse(_newBalanceInputController.text) -
                              widget._account.balance;
                      widget._account.addTransaction(Transaction(
                          widget._account.id,
                          description,
                          DateTime.now(),
                          amount));
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.pop(context);
                    },
                    child: Text(getAppLocalizations(context)!.confirm),
                  ))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(getAppLocalizations(context)!.cancel),
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
