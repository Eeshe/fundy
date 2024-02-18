import 'package:finman/core/models/debt_type.dart';
import 'package:finman/core/services/debt_service.dart';
import 'package:finman/ui/pages/debt_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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

  void saveData() {
    DebtService().save(this);
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

  Widget createDisplayWidget(BuildContext context, Function() redrawCallback) {
    TextStyle labelStyle = const TextStyle(fontSize: 20);
    return InkWell(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => DebtFormPage(this)));
        redrawCallback();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(id, style: labelStyle),
            _createProgressBarWidget(),
            ElevatedButton(
                onPressed: () {
                  if (!_isPaid()) {
                    _setPaid();
                  } else {
                    _clearPaid();
                  }
                  redrawCallback();
                },
                child: Text(
                  _isPaid()
                      ? getAppLocalizations(context)!.clear
                      : getAppLocalizations(context)!.payAll,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                )),
            Text(debtType.localized(context)),
          ],
        ),
      ),
    );
  }

  void delete() {
    DebtService().delete(this);
  }
}
