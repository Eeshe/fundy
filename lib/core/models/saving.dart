import 'dart:math';

import 'package:finman/core/models/account.dart';
import 'package:finman/core/services/saving_service.dart';
import 'package:finman/ui/pages/saving_form_page.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:finman/ui/shared/widgets/adjustable_progress_bar_widget.dart';
import 'package:finman/ui/shared/widgets/styled_progress_bar_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
    saveData();
  }

  void _clearPaid() {
    paidAmount = 0;
    saveData();
  }

  double calculateRemainingAmount() {
    return amount - paidAmount;
  }

  void increasePaidAmount(double amount) {
    paidAmount = max(0, min(this.amount, paidAmount + amount));
    saveData();
  }

  void delete() {
    SavingService().delete(this);
  }

  Widget _createAdjustableProgressBarWidget(
      ValueNotifier<double> paidAmountNotifier) {
    return AdjustableProgressBarWidget(
      filledPercentage: paidAmount / amount,
      lineHeight: 20,
      center: Text("\$${paidAmount.format()}/\$${amount.format()}",
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      onMin: () {
        _clearPaid();
        paidAmountNotifier.value = paidAmount;
      },
      onMax: () {
        _setPaid();
        paidAmountNotifier.value = paidAmount;
      },
      onTweak: (value) {
        increasePaidAmount(value);
        paidAmountNotifier.value = paidAmount;
      },
    );
  }

  Widget createDisplayWidget(
      BuildContext context, Account account, Function() redrawCallback) {
    TextStyle labelStyle = const TextStyle(fontSize: 20);
    ValueNotifier<double> paidAmountNotifier = ValueNotifier(paidAmount);
    return ValueListenableBuilder(
      valueListenable: paidAmountNotifier,
      builder: (context, value, child) {
        return InkWell(
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SavingFormPage(this, null)));
            redrawCallback();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(id, style: labelStyle),
              AccountIconWidget(account.iconPath, 50, 50),
              Text(accountId, style: labelStyle),
              _createAdjustableProgressBarWidget(paidAmountNotifier),
            ],
          ),
        );
      },
    );
  }

  Widget _createProgressBarWidget(BuildContext context) {
    return StyledProgressBarWidget(
      filledPercentage: paidAmount / amount,
      lineHeight: 20,
      center: Text(
        "\$${paidAmount.format()}/\$${amount.format()}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
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
