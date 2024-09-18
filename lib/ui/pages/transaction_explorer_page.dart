import 'package:flutter/material.dart';
import 'package:fundy/core/models/account.dart';
import 'package:fundy/core/providers/account_provider.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/account_icon_widget.dart';
import 'package:fundy/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:fundy/utils/date_time_extension.dart';
import 'package:provider/provider.dart';

class TransactionExplorerPage extends StatefulWidget {
  const TransactionExplorerPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionExplorerState();
}

class TransactionExplorerState extends State<TransactionExplorerPage> {
  final TextStyle _labelStyle = const TextStyle(fontSize: 20);

  final List<Account> _filteredAccounts = [];

  DateTime? _startingDate;
  DateTime? _endingDate;

  Widget _createAccountWidget(Account account) {
    return InkWell(
      onTap: () {
        if (_filteredAccounts.contains(account)) {
          _filteredAccounts.remove(account);
        } else {
          _filteredAccounts.add(account);
        }
        setState(() {});
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: _filteredAccounts.contains(account)
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AccountIconWidget(account.iconPath, 40, 40),
            const SizedBox(height: 15),
            Text(
              account.id,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Widget _createAccountSelectorWidget() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        List<Account> accounts =
            accountProvider.accounts.toList(); // Create a copy
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 130,
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) =>
                      _createAccountWidget(accounts[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _createDateButtonWidget(DateTime? date) {
    return ElevatedButton(
        onPressed: () {
          // TODO: Ask date
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onBackground),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            const SizedBox(width: 10),
            Text(
              date!.formatDayMonthYear(),
              style: const TextStyle(fontSize: 16),
            )
          ],
        ));
  }

  Widget _createDateSelectorWidget() {
    DateTime now = DateTime.now();
    _startingDate ??= DateTime(now.year, now.month, 1);
    _endingDate ??= DateTime(now.year, now.month + 1, 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _createDateButtonWidget(_startingDate),
        Icon(
          Icons.arrow_right_alt,
          color: Theme.of(context).colorScheme.onBackground,
          size: 30,
        ),
        _createDateButtonWidget(_endingDate)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.transactionExplorerBar),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
      ),
      body: ScrollablePageWidget(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                getAppLocalizations(context)!
                    .filteredAccounts(_filteredAccounts.length),
                style: _labelStyle),
            const SizedBox(height: 10),
            _createAccountSelectorWidget(),
            const SizedBox(height: 10),
            Text(
              getAppLocalizations(context)!.date,
              style: _labelStyle,
            ),
            const SizedBox(height: 10),
            _createDateSelectorWidget()
          ],
        ),
      ),
    );
  }
}
