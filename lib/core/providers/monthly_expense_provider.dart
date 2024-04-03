import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fundy/core/models/monthly_expense.dart';
import 'package:fundy/core/services/encryption_service.dart';
import 'package:hive/hive.dart';

class MonthlyExpenseProvider extends ChangeNotifier {
  List<MonthlyExpense> _monthlyExpenses = [];

  List<MonthlyExpense> get monthlyExpenses => _monthlyExpenses;

  Future<Box<MonthlyExpense>> _openBox() async {
    return await Hive.openBox<MonthlyExpense>('monthly_expenses',
        encryptionCipher: await EncryptionService().fetchEncryptionKey());
  }

  Future<void> fetchAll() async {
    final Box<MonthlyExpense> box = await _openBox();
    _monthlyExpenses = box.values.toList();
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
    notifyListeners();
  }

  Future<void> save(MonthlyExpense expense) async {
    if (await _findIndex(expense) != -1) {
      _update(expense);
      return;
    }
    final Box<MonthlyExpense> box = await _openBox();
    await box.add(expense);
    _monthlyExpenses.add(expense);
    notifyListeners();
  }

  Future<void> delete(MonthlyExpense expense) async {
    final Box<MonthlyExpense> box = await _openBox();
    final index = await _findIndex(expense);
    if (index == -1) return;

    await box.deleteAt(index);
    _monthlyExpenses.remove(expense);
    notifyListeners();
  }

  MonthlyExpense? getById(String expenseId) {
    return _monthlyExpenses
        .firstWhereOrNull((account) => account.id == expenseId);
  }
}
