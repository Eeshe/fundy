import 'package:finman/core/services/monthly_expense_service.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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

  void saveData() {
    MonthlyExpenseService().save(this);
  }

  bool isPaid(DateTime date) {
    String recordKey = createRecordKey(date);
    if (!paymentRecords.containsKey(recordKey)) return false;

    return paymentRecords[recordKey] == amount;
  }

  void setPaid(DateTime date) {
    paymentRecords[createRecordKey(date)] = amount;
    saveData();
  }

  void setUnpaid(DateTime date) {
    paymentRecords.remove(createRecordKey(date));
    saveData();
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
    paymentRecords[createRecordKey(date)] = currentRecord;
    saveData();
  }

  void delete() {
    MonthlyExpenseService().delete(this);
  }
}