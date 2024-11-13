import 'package:flutter/material.dart';
import 'package:fundy/core/models/monthly_expense.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/styled_progress_bar_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:hive/hive.dart';

import 'debt_type.dart';

part 'contributable.g.dart';


@HiveField(8)
class Contributable {
  @HiveField(0)
  String id;
  @HiveField(1)
  double amount;

  Contributable(this.id, this.amount);

  Widget _createDebtTypeWidget(BuildContext context) {
    if (debtType == null) return const SizedBox();

    return Text(
      debtType!.localized(context),
      style: TextStyle(
        fontSize: 12,
        color: debtType == DebtType.own
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  Widget createListWidget(
      BuildContext context, bool isSelected, Function() onTap) {
    Type type = runtimeType;
    bool isMonthlyExpense = type == MonthlyExpense;
    double paidAmount = 0;
    if (type == MonthlyExpense) {
      paidAmount = (this as MonthlyExpense).
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 90,
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
                  fontSize: 8,
                ),
              ),
              SizedBox(
                height: 45,
                child: Text(
                  id,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StyledProgressBarWidget(
                center: Text(
                  "\$${paidAmount.format()}/\$${amount.format()}",
                  style: const TextStyle(fontSize: 8),
                ),
                filledPercentage: paidAmount / amount,
                lineHeight: 10,
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