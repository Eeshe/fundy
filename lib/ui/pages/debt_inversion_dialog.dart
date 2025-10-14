import 'package:flutter/material.dart';
import 'package:fundy/core/models/debt.dart';
import 'package:fundy/core/models/debt_inversion_option.dart';
import 'package:fundy/core/models/debt_type.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/utils/double_extension.dart';

class DebtInversionDialog extends StatelessWidget {
  final Debt _debt;
  final double _newOwedAmount;

  const DebtInversionDialog(this._debt, this._newOwedAmount, {super.key});

  Widget _createDialogOptionButton(BuildContext context, String text,
      DebtInversionOption debtInversionOption, Color? backgroundColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 50),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onPressed: () {
        Navigator.pop(context, debtInversionOption);
      },
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String inversionLocalization = _debt.debtType == DebtType.own
        ? getAppLocalizations(context)!
            .debtInversionDialogInvertToOther(_newOwedAmount.format())
        : getAppLocalizations(context)!
            .debtInversionDialogInvertToOwn(_newOwedAmount.format());
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            getAppLocalizations(context)!.debtInversionDialog(_debt.id),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          _createDialogOptionButton(
            context,
            inversionLocalization,
            DebtInversionOption.invert,
            Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          _createDialogOptionButton(
            context,
            getAppLocalizations(context)!.debtInversionDialogIgnore,
            DebtInversionOption.ignore,
            null,
          ),
          const SizedBox(height: 10),
          _createDialogOptionButton(
            context,
            getAppLocalizations(context)!.debtInversionDialogDelete,
            DebtInversionOption.delete,
            Theme.of(context).colorScheme.error,
          )
        ],
      ),
    );
  }
}
