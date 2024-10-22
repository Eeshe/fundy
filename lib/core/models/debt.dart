import 'dart:math';

import 'package:fundy/core/models/debt_type.dart';
import 'package:fundy/core/providers/debt_provider.dart';
import 'package:fundy/ui/pages/debt_form_page.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/adjustable_progress_bar_widget.dart';
import 'package:fundy/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

part 'debt.g.dart';

@HiveType(typeId: 6)
class Debt {
  @HiveField(0)
  String id;
  @HiveField(1)
  DebtType debtType;
  @HiveField(2)
  double amount;
  @HiveField(3)
  double paidAmount;

  Debt(this.id, this.debtType, this.amount, this.paidAmount);

  void increasePaidAmount(double amount) {
    paidAmount = max(0, min(this.amount, paidAmount + amount));
  }

  bool _isPaid() {
    return paidAmount >= amount;
  }

  void _setPaid() {
    paidAmount = amount;
  }

  void _clearPaid() {
    paidAmount = 0;
  }

  double calculateRemainingAmount() {
    return amount - paidAmount;
  }

  Widget _createProgressBarWidget() {
    return LinearPercentIndicator(
      animation: true,
      lineHeight: 20,
      barRadius: const Radius.circular(10),
      progressColor: debtType == DebtType.own ? Colors.red : Colors.green,
      percent: paidAmount / amount,
      center: Text(
        "\$${paidAmount.toStringAsFixed(2)}/\$${amount.toStringAsFixed(2)}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget createDisplayWidget(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushNamed(context, '/debt_form',
              arguments: DebtFormArguments(this));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              id,
              style: const TextStyle(fontSize: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  debtType.localized(context),
                  style: TextStyle(
                    fontSize: 16,
                    color: debtType == DebtType.own
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Text(getAppLocalizations(context)!.remainingAmount("\$${(amount - paidAmount).format()}"))
              ],
            ),
            AdjustableProgressBarWidget(
              filledPercentage: paidAmount / amount,
              lineHeight: 20,
              center: Text("\$${paidAmount.format()}/\$${amount.format()}"),
              onMin: () {
                _clearPaid();
                Provider.of<DebtProvider>(context, listen: false).save(this);
              },
              onMax: () {
                _setPaid();
                Provider.of<DebtProvider>(context, listen: false).save(this);
              },
              onTweak: (value) {
                increasePaidAmount(value);
                Provider.of<DebtProvider>(context, listen: false).save(this);
              },
            )
          ],
        ),
      ),
    );
  }
}
