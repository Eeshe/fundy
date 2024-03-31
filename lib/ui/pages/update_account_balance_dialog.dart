import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/models/transaction.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/text_input_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:fundy/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateBalanceDialog extends StatefulWidget {
  final Account _account;

  const UpdateBalanceDialog(this._account, {super.key});

  @override
  State<StatefulWidget> createState() => UpdateBalanceDialogStage();
}

class UpdateBalanceDialogStage extends State<UpdateBalanceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newBalanceInputController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(getAppLocalizations(context)!.updateBalance),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getAppLocalizations(context)!.newBalanceInstructions),
          Form(
            key: _formKey,
            child: TextInputWidget(
              inputController: _newBalanceInputController,
              hintText: widget._account.balance.format(),
              textInputType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return getAppLocalizations(context)!.emptyNewBalance;
                }
                if (!value.isNumeric()) {
                  return getAppLocalizations(context)!.nonNumberAmount;
                }
                if (double.parse(value) < 0) {
                  return getAppLocalizations(context)!.lessThanZeroNewBalance;
                }
                return null;
              },
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            getAppLocalizations(context)!.cancel,
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            String description = getAppLocalizations(context)!.balanceUpdate;
            double amount = double.parse(_newBalanceInputController.text) -
                widget._account.balance;
            widget._account.addTransaction(Transaction(widget._account.id,
                description, DateTime.now(), amount, false));
            Provider.of<AccountProvider>(context, listen: false)
                .save(widget._account);
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          },
          child: Text(
            getAppLocalizations(context)!.update,
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
        )
      ],
    );
  }
}
