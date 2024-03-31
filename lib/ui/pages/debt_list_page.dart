import 'package:fundy/core/models/debt.dart';
import 'package:fundy/core/models/debt_type.dart';
import 'package:fundy/core/providers/debt_provider.dart';
import 'package:fundy/ui/pages/debt_form_page.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:fundy/ui/shared/widgets/empty_list_widget.dart';
import 'package:fundy/ui/shared/widgets/styled_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebtListPage extends StatefulWidget {
  const DebtListPage({super.key});

  @override
  State<StatefulWidget> createState() => DebtListState();
}

class DebtListState extends State<DebtListPage> {
  String? _filteredDebtType;

  Widget _createDebtTypeRadio(String debtTypeName) {
    return Row(
      children: [
        Radio(
            value: debtTypeName,
            groupValue: _filteredDebtType,
            onChanged: (value) =>
                setState(() => _filteredDebtType = value.toString())),
          Text(
            debtTypeName,
            style: const TextStyle(fontSize: 16),
          )
      ],
    );
  }

  Row _createDebtTypeRadios() {
    List<Widget> radios = [];
    radios.add(_createDebtTypeRadio(getAppLocalizations(context)!.all));
    for (DebtType debtType in DebtType.values) {
      radios.add(_createDebtTypeRadio(debtType.localized(context)));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: radios,
    );
  }

  Widget _createNewDebtButton() {
    return StyledButtonWidget(
      text: getAppLocalizations(context)!.newText,
      onPressed: () {
        Navigator.pushNamed(context, '/debt_form',
            arguments: DebtFormArguments(null));
      },
    );
  }

  Widget _createDebtListWidget() {
    return Consumer<DebtProvider>(
      builder: (context, debtProvider, child) {
        List<Debt> debts = debtProvider.debts.toList();
        if (_filteredDebtType != getAppLocalizations(context)!.all) {
          debts.removeWhere((element) =>
              element.debtType.localized(context) != _filteredDebtType!);
        }
        if (debts.isEmpty) {
          return EmptyListWidget(
            title: getAppLocalizations(context)!.noDebtsFound,
            subtitle: getAppLocalizations(context)!.createDebtInstruction,
          );
        }
        return ListView.separated(
            itemBuilder: (context, index) =>
                debts[index].createDisplayWidget(context),
            separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.primary,
                ),
            itemCount: debts.length);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _filteredDebtType ??= getAppLocalizations(context)!.all;
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.debts),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _createDebtTypeRadios(),
            _createNewDebtButton(),
            Expanded(child: Center(child: _createDebtListWidget())),
          ],
        ),
      ),
    );
  }
}
