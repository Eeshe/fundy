import 'package:finman/core/models/debt.dart';
import 'package:hive/hive.dart';

class DebtService {
  static final DebtService _singleton = DebtService._internal();

  factory DebtService() {
    return _singleton;
  }

  DebtService._internal();

  Future<Box<Debt>> _openBox() async {
    return await Hive.openBox<Debt>('debt');
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
  }

  Future<void> save(Debt debt) async {
    if (await _findIndex(debt) != -1) {
      _update(debt);
      return;
    }
    final Box<Debt> box = await _openBox();
    await box.add(debt);
  }

  Future<List<Debt>> fetchAll() async {
    final Box<Debt> box = await _openBox();
    return box.values.toList();
  }

  Future<void> delete(Debt debt) async {
    final Box<Debt> box = await _openBox();
    final index = await _findIndex(debt);
    if (index == -1) return;

    await box.deleteAt(index);
  }
}