import 'dart:math';

import 'package:finman/core/providers/monthly_expense_provider.dart';
import 'package:finman/ui/pages/expense_form_page.dart';
import 'package:finman/ui/shared/widgets/adjustable_progress_bar_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

part 'monthly_expense.g.dart';

@HiveType(typeId: 3)
class MonthlyExpense {
  @HiveField(0)
  String id;
  @HiveField(1)
  double amount;
  @HiveField(2)
  DateTime paymentDate;
  @HiveField(3)
  final Map<String, double> paymentRecords;

  MonthlyExpense.create(this.id, this.amount, this.paymentDate)
      : paymentRecords = {'${DateTime.now().month}-${DateTime.now().year}': 0};

  MonthlyExpense(this.id, this.amount, this.paymentDate, this.paymentRecords);

  static String createRecordKey(DateTime dateTime) {
    return DateFormat('MMMM-y').format(dateTime);
  }

  bool isPaid(DateTime date) {
    String recordKey = createRecordKey(date);
    if (!paymentRecords.containsKey(recordKey)) return false;

    return paymentRecords[recordKey] == amount;
  }

  void setPaid(DateTime date) {
    paymentRecords[createRecordKey(date)] = amount;
  }

  void setUnpaid(DateTime date) {
    paymentRecords.remove(createRecordKey(date));
  }

  double getPaymentRecord(DateTime date) {
    String recordKey = createRecordKey(date);
    if (!paymentRecords.containsKey(recordKey)) return 0;

    return paymentRecords[recordKey]!;
  }

  double getRemainingPayment(DateTime date) {
    return amount - getPaymentRecord(date);
  }

  void addPayment(DateTime date, double amount) {
    double currentRecord = getPaymentRecord(date);
    currentRecord += amount;
    paymentRecords[createRecordKey(date)] =
        min(this.amount, max(0, currentRecord));
  }

  Widget createListWidget(BuildContext context, DateTime date) {
    double paidAmount = getPaymentRecord(date);
    double paidPercentage = paidAmount / amount;
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseFormPage(this, date),
            ));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            id,
            style: const TextStyle(fontSize: 24),
          ),
          AdjustableProgressBarWidget(
            filledPercentage: paidPercentage,
            lineHeight: 20,
            center: Text("\$${paidAmount.format()}/\$${amount.format()}"),
            onMin: () {
              setUnpaid(date);
              Provider.of<MonthlyExpenseProvider>(context, listen: false)
                  .save(this);
            },
            onMax: () {
              setPaid(date);
              Provider.of<MonthlyExpenseProvider>(context, listen: false)
                  .save(this);
            },
            onTweak: (value) {
              addPayment(date, value);
              Provider.of<MonthlyExpenseProvider>(context, listen: false)
                  .save(this);
            },
          )
        ],
      ),
    );
  }
}