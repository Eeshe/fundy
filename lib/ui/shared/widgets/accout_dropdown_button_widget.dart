import 'package:finman/core/models/account.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:flutter/material.dart';

class AccountDropdownButtonWidget extends StatefulWidget {
  final Account? account;
  final Function(Account? account)? onChanged;
  final String? Function(Account?)? validator;

  const AccountDropdownButtonWidget(
      {super.key, this.account, this.onChanged, this.validator});

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
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            border: Border.all(
                color: Theme.of(context).colorScheme.primary, width: 3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButtonFormField<Account>(
            padding: const EdgeInsets.only(left: 5, right: 5),
            decoration: const InputDecoration(
                errorMaxLines: 3, enabledBorder: InputBorder.none),
            isExpanded: true,
            validator: widget.validator,
            value: widget.account,
            items: accounts
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        AccountIconWidget(e.iconPath, 30, 30),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            e.id,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: widget.onChanged,
          ),
        );
      },
    );
  }
}
