import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/ui/shared/widgets/account_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        List<Account> accounts = accountProvider.accounts;
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
