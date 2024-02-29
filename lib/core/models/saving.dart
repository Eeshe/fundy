import 'package:finman/core/models/account.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/core/services/saving_service.dart';
import 'package:finman/ui/pages/saving_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

part 'saving.g.dart';

@HiveType(typeId: 4)
class Saving {
  @HiveField(0)
  String id;
  @HiveField(1)
  String accountId;
  @HiveField(2)
  double amount;
  @HiveField(3)
  double paidAmount;

  Saving(this.id, this.accountId, this.amount, this.paidAmount);

  void saveData() {
    SavingService().save(this);
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

  Widget _createProgressBarWidget(BuildContext context) {
    return LinearPercentIndicator(
      animation: true,
      lineHeight: 20,
      barRadius: const Radius.circular(5),
      progressColor: Theme.of(context).colorScheme.primary,
      percent: paidAmount / amount,
      center: Text(
        "\$${paidAmount.toStringAsFixed(2)}/\$${amount.toStringAsFixed(2)}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  void delete() {
    SavingService().delete(this);
  }

  Widget createDisplayWidget(BuildContext context, Function() redrawCallback) {
    TextStyle labelStyle = const TextStyle(fontSize: 20);
    return FutureBuilder(
        future: AccountService().fetch(accountId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          Account account = snapshot.data!;
          return InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SavingFormPage(this, null)));
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
                  AccountIconWidget(account.iconPath, 50, 50),
                  Text(accountId, style: labelStyle),
                  _createProgressBarWidget(context),
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
                      ))
                ],
              ),
            ),
          );
        });
  }

  Widget createListWidget(
      BuildContext context, Account account, Function() redrawCallback) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SavingFormPage(this, account)));
        redrawCallback();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              id,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          _createProgressBarWidget(context)
        ],
      ),
    );
  }
}
