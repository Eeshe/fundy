import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/services/encryption_service.dart';
import 'package:hive/hive.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  Future<Box<Account>> _openBox() async {
    return await Hive.openBox<Account>('accounts',
        encryptionCipher: await EncryptionService().fetchEncryptionKey());
  }

  Future<void> fetchAll() async {
    final box = await _openBox();
    _accounts = box.values.toList().cast<Account>();
  }

  Future<Account?> fetch(String accountId) async {
    final box = await _openBox();
    final account = box.getAt(await _findIndex(accountId));
    if (account == null) return null;

    return account;
  }

  Future<int> _findIndex(String accountId) async {
    final accounts = (await _openBox()).values.toList().cast<Account>();
    return accounts.indexWhere((account) {
      return account.id == accountId;
    });
  }

  Future<void> _update(Account updatedAccount) async {
    final box = await _openBox();
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
    final box = await _openBox();
    await box.add(account);
    notifyListeners();
  }

  Future<void> delete(Account account) async {
    final box = await _openBox();
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
