import 'package:finman/core/models/saving.dart';
import 'package:finman/core/providers/saving_provider.dart';
import 'package:finman/ui/pages/saving_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/empty_list_widget.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingListPage extends StatefulWidget {
  const SavingListPage({super.key});

  @override
  State<StatefulWidget> createState() => SavingListPageState();
}

class SavingListPageState extends State<SavingListPage> {

  Widget _createNewSavingButton() {
    return StyledButtonWidget(
      text: getAppLocalizations(context)!.newText,
      onPressed: () {
        Navigator.pushNamed(context, '/saving_form',
            arguments: SavingFormArguments(null, null));
      },
    );
  }

  Widget _createSavingListWidget() {
    return Consumer<SavingProvider>(
      builder: (context, savingProvider, child) {
        List<Saving> savings = savingProvider.savings;
        if (savings.isEmpty) {
          return EmptyListWidget(
            title: getAppLocalizations(context)!.noSavingsFound,
            subtitle: getAppLocalizations(context)!.createSavingInstruction,
          );
        }
        return ListView.separated(
            itemBuilder: (context, index) {
              return savings[index].createDisplayWidget(context);
            },
            separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
            itemCount: savings.length);
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
