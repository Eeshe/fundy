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
  List<Widget>? _savingWidgets;

  Future<void> _fetchSavings() async {
    _savingWidgets = [];
    for (Saving saving in await SavingService().fetchAll()) {
      Account? account = await AccountService().fetch(saving.accountId);
      if (account == null) continue;
      if (!context.mounted) continue;

      _savingWidgets?.add(
          saving.createDisplayWidget(context, account, () => setState(() {})));
    }
  }

  Widget _createNewSavingButton() {
    return StyledButtonWidget(
      text: getAppLocalizations(context)!.newText,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SavingFormPage(null, null),
            ));
        setState(() {});
      },
    );
  }

  Widget _createSavingListWidget() {
    if (_savingWidgets!.isEmpty) {
      return EmptyListWidget(
        title: getAppLocalizations(context)!.noSavingsFound,
        subtitle: getAppLocalizations(context)!.createSavingInstruction,
      );
    }
    return ListView.separated(
        itemBuilder: (context, index) => _savingWidgets![index],
        separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
        itemCount: _savingWidgets!.length);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchSavings(),
      builder: (context, snapshot) {
        if (_savingWidgets == null) return const SizedBox();

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
      },
    );
  }
}
