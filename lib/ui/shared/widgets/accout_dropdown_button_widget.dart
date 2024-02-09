import 'package:finman/core/models/account.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:flutter/material.dart';

class AccountDropdownButtonWidget extends StatefulWidget {
  final Account? account;
  final Function(Account? account) onChanged;

  const AccountDropdownButtonWidget(this.account, this.onChanged, {super.key});

  @override
  State<StatefulWidget> createState() => AccountDropdownButtonState();
}

class AccountDropdownButtonState extends State<AccountDropdownButtonWidget> {
  Future<List<Account>> _fetchAccounts() async {
    return await AccountService().fetchAll();
  }

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchAccounts(),
        builder: (context, snapshot) {
          List<Account> accounts;
          if (!snapshot.hasData) {
            accounts = [];
          } else {
            accounts = snapshot.data!;
          }
          return DropdownButton<Account>(
            value: widget.account,
            items: accounts
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        AccountIconWidget(e.iconPath, 50, 50),
                        Text(e.id)
                      ],
                    )))
                .toList(),
            onChanged: widget.onChanged,
          );
        });
  }
}
