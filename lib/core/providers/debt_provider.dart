import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fundy/core/models/contributable.dart';
import 'package:fundy/core/models/debt.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/core/services/encryption_service.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class DebtProvider extends ChangeNotifier {
  List<Debt> _debts = [];

  List<Debt> get debts => _debts;

  Future<Box<Debt>> _openBox() async {
    return await Hive.openBox<Debt>('debts',
        encryptionCipher: await EncryptionService().fetchEncryptionKey());
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

  Future<void> delete(BuildContext context, Debt debt) async {
    final Box<Debt> box = await _openBox();
    final index = await _findIndex(debt);
    if (index == -1) return;

    await box.deleteAt(index);
    _debts.remove(debt);

    // Delete any transaction contribution referrencing the Debt
    for (var account
        in Provider.of<AccountProvider>(context, listen: false).accounts) {
      for (var transaction in account.transactions) {
        Contributable? contributable = transaction.contributable;
        if (contributable == null) continue;
        if (contributable is! Debt) continue;
        if (contributable.id != debt.id) continue;

        transaction.contributable = null;
      }
    }
    notifyListeners();
  }

  Debt? getById(String debtId) {
    return _debts.firstWhereOrNull((debt) => debt.id == debtId);
  }
}

