import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/providers/account_provider.dart';
import 'package:finman/ui/pages/account_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/empty_list_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<StatefulWidget> createState() => AccountListPageState();
}

class AccountListPageState extends State<AccountListPage> {
  String? _filteredCurrency;

  @override
  void initState() {
    super.initState();
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

  Widget _createNewAccountButtonWidget() {
    return StyledButtonWidget(
      text: getAppLocalizations(context)!.newText,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountFormPage(),
            ));
      },
    );
  }

  Widget _createAccountListWidget() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        List<Account> accounts = accountProvider.accounts.toList();
        if (_filteredCurrency != getAppLocalizations(context)!.all) {
          accounts.removeWhere((element) =>
              element.currencyType.name != _filteredCurrency!.toLowerCase());
        }
        if (accounts.isEmpty) {
          return EmptyListWidget(
            title: getAppLocalizations(context)!.noAccountsFound,
            subtitle: getAppLocalizations(context)!.createAccountInstruction,
          );
        }
        accounts.sort((a, b) => b.balance.compareTo(a.balance));
        return ListView.separated(
          padding: const EdgeInsets.only(left: 10, right: 10),
          itemBuilder: (context, index) =>
              accounts[index].createListWidget(context),
          separatorBuilder: (context, index) => Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
          itemCount: accounts.length,
        );
      },
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
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.yourAccounts),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          resizeToAvoidBottomInset: true,
          body: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  _createCurrencyRadios(),
                  _createNewAccountButtonWidget(),
            Expanded(child: Center(child: _createAccountListWidget())),
          ],
        ),
      ),
        );
  }
}
