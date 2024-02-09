import 'package:finman/core/models/account.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/pages/create_account_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:flutter/material.dart';

import '../shared/widgets/account_icon_widget.dart';
import 'account_view_page.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<StatefulWidget> createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  String? _filteredCurrency;

  Future<List<Account>> _fetchAccounts() async {
    List<Account> accounts = await AccountService().fetchAll();
    accounts.sort((a, b) => b.balance.compareTo(a.balance));

    return accounts;
  }

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Widget _createAccountWidget(Account account) {
    return InkWell(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountViewPage(account),
              ));
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: AccountIconWidget(account.iconPath, 50, 50),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.id,
                      style: const TextStyle(fontSize: 26),
                    ),
                    Text(
                      account.formatBalance(false),
                      style: const TextStyle(fontSize: 20),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _createAccountListWidget(List<Account> accounts) {
    if (_filteredCurrency != getAppLocalizations(context)!.all) {
      accounts.removeWhere((element) =>
          element.currencyType.name != _filteredCurrency!.toLowerCase());
    }
    if (accounts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            color: Colors.red,
          ),
          Text(
            getAppLocalizations(context)!.noAccountsFound,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36),
          ),
          Text(
            getAppLocalizations(context)!.createAccountInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          )
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black45,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.0)),
      child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              _createAccountWidget(accounts[index]),
          separatorBuilder: (context, index) => const Divider(),
          itemCount: accounts.length),
    );
  }

  Widget _createErrorWidget() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          Text(
            getAppLocalizations(context)!.accountFetchingError,
            style: const TextStyle(fontSize: 36),
          )
        ],
      ),
    );
  }

  Widget _createLoadingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        Text(
          getAppLocalizations(context)!.fetchingAccounts,
          style: const TextStyle(fontSize: 36),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _filteredCurrency ??= getAppLocalizations(context)!.all;
    return FutureBuilder<List<Account>>(
      future: _fetchAccounts(),
      builder: (context, snapshot) {
        Widget listWidget;
        if (snapshot.hasData) {
          List<Account> accounts = snapshot.data!;
          listWidget = _createAccountListWidget(accounts);
        } else if (snapshot.hasError) {
          listWidget = _createErrorWidget();
        } else {
          listWidget = _createLoadingWidget();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(getAppLocalizations(context)!.yourAccounts),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: DropdownButton<String>(
                      value: _filteredCurrency,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      items: [
                        getAppLocalizations(context)!.all,
                        'Bs',
                        'USD',
                        'USDT'
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _filteredCurrency = value!;
                        });
                      },
                    ),
                  ),
                  listWidget
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAccountPage(),
                  ));
              setState(() {});
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
