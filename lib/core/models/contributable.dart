import 'package:flutter/material.dart';
import 'package:fundy/core/models/debt.dart';
import 'package:fundy/core/models/monthly_expense.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/styled_progress_bar_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:hive/hive.dart';

import 'debt_type.dart';

part 'contributable.g.dart';


@HiveType(typeId: 7)
class Contributable {
  @HiveField(0)
  String id;
  @HiveField(1)
  double amount;

  Contributable(this.id, this.amount);

  Widget _createDebtTypeWidget(BuildContext context) {
    if (runtimeType != Debt) return const SizedBox();

    Debt debt = this as Debt;
    DebtType? debtType = debt.debtType;

    return Text(
      debtType.localized(context),
      style: TextStyle(
        fontSize: 14,
        color: debtType == DebtType.own
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  Widget createContributableListWidget(BuildContext context, DateTime? dateTime,
      bool isSelected, Function() onTap) {
    Type type = runtimeType;
    bool isMonthlyExpense = type == MonthlyExpense;
    double paidAmount = 0;
    if (type == MonthlyExpense) {
      paidAmount = (this as MonthlyExpense).getPaymentRecord(dateTime!);
    } else {
      paidAmount = (this as Debt).paidAmount;
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isMonthlyExpense
                    ? getAppLocalizations(context)!.monthlyExpense
                    : getAppLocalizations(context)!.debt,
                style: const TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 45,
                child: Center(
                  child: Text(
                    id,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              StyledProgressBarWidget(
                center: Text(
                  "\$${paidAmount.format()}/\$${amount.format()}",
                  style: const TextStyle(fontSize: 12),
                ),
                filledPercentage: paidAmount / amount,
                lineHeight: 20,
                // boxDecoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(5),
                // ),
              ),
              const Spacer(),
              _createDebtTypeWidget(context)
            ],
          ),
        ),
      ),
    );
  }
}
