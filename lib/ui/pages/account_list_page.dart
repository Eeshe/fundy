import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/ui/pages/create_account_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:flutter/material.dart';

import '../shared/widgets/account_icon_widget.dart';
import 'account_page.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<StatefulWidget> createState() => AccountListPageState();
}

class AccountListPageState extends State<AccountListPage> {
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

  Row _createCurrencyRadio(String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _filteredCurrency,
          onChanged: (value) {
            setState(() {
              _filteredCurrency = value;
            });
          },
        ),
        Text(value)
      ],
    );
  }

  Widget _createCurrencyRadios() {
    List<Row> radios = [];
    radios.add(_createCurrencyRadio(getAppLocalizations(context)!.all));
    for (var element in CurrencyType.values) {
      radios.add(_createCurrencyRadio(element.displayName));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: radios,
    );
  }

  Widget _createAccountWidget(Account account) {
    return InkWell(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountPage(account),
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
          Icon(
            Icons.search_off,
            color: Theme.of(context).colorScheme.error,
          ),
          Text(
            getAppLocalizations(context)!.noAccountsFound,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30),
          ),
          Text(
            getAppLocalizations(context)!.createAccountInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          )
        ],
      );
    }
    return Expanded(child: ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 10, right: 10),
      itemBuilder: (context, index) =>
          accounts[index].createListWidget(context, () => setState(() {})),
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).colorScheme.primary,
      ),
      itemCount: accounts.length,
    ));
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

  Widget _createFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAccountPage(),
            ));
        setState(() {});
      },
      child: const Icon(Icons.add),
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
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              _createCurrencyRadios(),
              listWidget,
            ],
          ),
          floatingActionButton: _createFloatingActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
