import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/saving.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/core/services/saving_service.dart';
import 'package:finman/ui/pages/saving_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/empty_list_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:flutter/material.dart';

class SavingListPage extends StatefulWidget {
  const SavingListPage({super.key});

  @override
  State<StatefulWidget> createState() => SavingListPageState();
}

class SavingListPageState extends State<SavingListPage> {
  Map<Saving, Account>? _savingsMap;

  Future<void> _fetchSavings() async {
    Map<Saving, Account> savingsMap = <Saving, Account>{};
    for (Saving saving in await SavingService().fetchAll()) {
      Account? account = await AccountService().fetch(saving.accountId);
      if (account == null) continue;

      savingsMap[saving] = account;
    }
    _savingsMap = savingsMap;
  }

  Widget _createNewSavingButton() {
    return StyledButtonWidget(
      text: getAppLocalizations(context)!.newText,
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SavingFormPage(null, null),
            ));
        setState(() {});
      },
    );
  }

  Widget _createSavingListWidget() {
    return FutureBuilder(
      future: _fetchSavings(),
      builder: (context, snapshot) {
        if (_savingsMap == null) {
          print("A");
        }
        if (_savingsMap!.isEmpty) {
          print("B");
          return EmptyListWidget(
            title: getAppLocalizations(context)!.noSavingsFound,
            subtitle: getAppLocalizations(context)!.createSavingInstruction,
          );
        }
        return ListView.separated(
            itemBuilder: (context, index) {
              Saving saving = _savingsMap!.keys.toList()[index];
              return saving.createDisplayWidget(
                  context, _savingsMap![saving]!, () => setState(() {}));
            },
            separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
            itemCount: _savingsMap!.length);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.savings),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _createNewSavingButton(),
                  Expanded(child: Center(child: _createSavingListWidget())),
                ],
              )),
        );
  }
}
