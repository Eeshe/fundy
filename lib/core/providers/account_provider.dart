import 'package:finman/core/models/account.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class AccountProvider extends ChangeNotifier {
  final String _accountsBox = "accounts";
  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  Future<void> fetchAll() async {
    final box = await Hive.openBox(_accountsBox);
    _accounts = box.values.toList().cast<Account>();
  }

  Future<Account?> fetch(String accountId) async {
    final box = await Hive.openBox(_accountsBox);
    final account = box.getAt(await _findIndex(accountId));
    if (account == null) return null;

    return account as Account;
  }

  Future<int> _findIndex(String accountId) async {
    final accounts =
        (await Hive.openBox(_accountsBox)).values.toList().cast<Account>();
    return accounts.indexWhere((account) {
      return account.id == accountId;
    });
  }

  Future<void> _update(Account updatedAccount) async {
    final box = await Hive.openBox(_accountsBox);
    final index = await _findIndex(updatedAccount.id);
    if (index == -1) return;

    await box.putAt(index, updatedAccount);
    notifyListeners();
  }

  Future<void> save(Account account) async {
    int index = await _findIndex(account.id);
    if (index != -1) {
      _update(account);
      return;
    }
    _accounts.add(account);
    final box = await Hive.openBox(_accountsBox);
    await box.add(account);
    notifyListeners();
  }

  Future<void> delete(Account account) async {
    final box = await Hive.openBox(_accountsBox);
    final index = await _findIndex(account.id);
    if (index == -1) return;
    
    _accounts.remove(account);
    await box.deleteAt(index);
    notifyListeners();
  }

  Account? getById(String accountId) {
    return _accounts.firstWhereOrNull((account) => account.id == accountId);
  }
}
