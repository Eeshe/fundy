import 'package:collection/collection.dart';
import 'package:fundy/core/models/debt.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DebtProvider extends ChangeNotifier {
  List<Debt> _debts = [];

  List<Debt> get debts => _debts;

  Future<Box<Debt>> _openBox() async {
    return await Hive.openBox<Debt>('debts');
  }

  Future<void> fetchAll() async {
    final Box<Debt> box = await _openBox();
    _debts = box.values.toList();
  }

  Future<int> _findIndex(Debt debt) async {
    final Box<Debt> box = await _openBox();
    final List<Debt> debts = box.values.toList();
    return debts.indexWhere((e) => e.id == debt.id);
  }

  Future<void> _update(Debt debt) async {
    final Box<Debt> box = await _openBox();
    final index = await _findIndex(debt);
    if (index == -1) return;

    await box.putAt(index, debt);
    notifyListeners();
  }

  Future<void> save(Debt debt) async {
    if (await _findIndex(debt) != -1) {
      _update(debt);
      return;
    }
    final Box<Debt> box = await _openBox();
    await box.add(debt);
    _debts.add(debt);
    notifyListeners();
  }

  Future<void> delete(Debt debt) async {
    final Box<Debt> box = await _openBox();
    final index = await _findIndex(debt);
    if (index == -1) return;

    await box.deleteAt(index);
    _debts.remove(debt);
    notifyListeners();
  }

  Debt? getById(String debtId) {
    return _debts.firstWhereOrNull((debt) => debt.id == debtId);
  }
}