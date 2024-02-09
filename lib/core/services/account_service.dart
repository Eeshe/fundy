import 'package:finman/core/models/account.dart';
import 'package:hive/hive.dart';

class AccountService {
  final String _accountsBox = 'accounts';

  AccountService();

  AccountService._();

  static final AccountService _instance = AccountService._();

  factory AccountService.getInstance() => _instance;

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

    if (index != -1) {
      await box.putAt(index, updatedAccount);
    }
  }

  Future<void> save(Account account) async {
    int index = await _findIndex(account.id);
    if (index != -1) {
      _update(account);
      return;
    }
    final box = await Hive.openBox(_accountsBox);
    await box.add(account);
  }

  Future<Account?> fetch(String accountId) async {
    final box = await Hive.openBox(_accountsBox);
    final account = box.getAt(await _findIndex(accountId));
    if (accountId == 'Test3') {
      print("ACCOUNT ID: $accountId");
      print("INDEX: ${await _findIndex(accountId)}");
      print("FETCHED ACCOUNT: $account");
    }
    if (account == null) return null;

    return account as Account;
  }

  Future<List<Account>> fetchAll() async {
    final box = await Hive.openBox(_accountsBox);
    return box.values.toList().cast<Account>();
  }

  Future<void> delete(Account accountToDelete) async {
    final box = await Hive.openBox(_accountsBox);
    final index = await _findIndex(accountToDelete.id);
    if (index == -1) return;

    await box.deleteAt(index);
  }
}
