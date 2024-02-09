import 'package:finman/core/models/monthly_expense.dart';
import 'package:hive/hive.dart';

class MonthlyExpenseService {
  static final MonthlyExpenseService _singleton =
      MonthlyExpenseService._internal();

  factory MonthlyExpenseService() {
    return _singleton;
  }

  MonthlyExpenseService._internal();

  Future<Box<MonthlyExpense>> _openBox() async {
    return await Hive.openBox<MonthlyExpense>('monthly_expenses');
  }

  Future<int> _findIndex(MonthlyExpense expense) async {
    final Box<MonthlyExpense> box = await _openBox();
    final List<MonthlyExpense> expenses = box.values.toList();
    return expenses.indexWhere((e) => e.id == expense.id);
  }

  Future<void> _update(MonthlyExpense expense) async {
    final Box<MonthlyExpense> box = await _openBox();
    final index = await _findIndex(expense);
    if (index == -1) return;

    await box.putAt(index, expense);
  }

  Future<void> save(MonthlyExpense expense) async {
    if (await _findIndex(expense) != -1) {
      _update(expense);
      return;
    }
    final Box<MonthlyExpense> box = await _openBox();
    await box.add(expense);
  }

  Future<List<MonthlyExpense>> fetchAll() async {
    final Box<MonthlyExpense> box = await _openBox();
    return box.values.toList();
  }

  Future<void> delete(MonthlyExpense expense) async {
    final Box<MonthlyExpense> box = await _openBox();
    final index = await _findIndex(expense);
    if (index == -1) return;

    await box.deleteAt(index);
  }
}
