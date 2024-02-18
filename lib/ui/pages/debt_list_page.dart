import 'package:finman/core/models/debt.dart';
import 'package:finman/core/models/debt_type.dart';
import 'package:finman/core/services/debt_service.dart';
import 'package:finman/ui/pages/debt_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:flutter/material.dart';

class DebtListPage extends StatefulWidget {
  const DebtListPage({super.key});

  @override
  State<StatefulWidget> createState() => DebtListState();
}

class DebtListState extends State<DebtListPage> {
  String? _filteredDebtType;

  Widget _createErrorWidget() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          Text(
            getAppLocalizations(context)!.debtFetchingError,
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
          getAppLocalizations(context)!.fetchingDebts,
          style: const TextStyle(fontSize: 36),
        )
      ],
    );
  }

  Widget _createNoDebtsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.search_off,
          color: Colors.red,
        ),
        Text(
          getAppLocalizations(context)!.noDebtsFound,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36),
        ),
        Text(
          getAppLocalizations(context)!.createDebtInstruction,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        )
      ],
    );
  }

  Expanded _createDebtTypeRadio(String debtTypeName) {
    return Expanded(
      flex: 1,
      child: Row(
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
      ),
    );
  }

  Row _createDebtTypeRadios() {
    List<Expanded> radios = [];
    radios.add(_createDebtTypeRadio(getAppLocalizations(context)!.all));
    for (DebtType debtType in DebtType.values) {
      radios.add(_createDebtTypeRadio(debtType.localized(context)));
    }
    return Row(children: radios);
  }

  Widget _createDebtListWidget() {
    return FutureBuilder(
        future: DebtService().fetchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _createLoadingWidget();
          } else if (snapshot.hasError) {
            return _createErrorWidget();
          }
          List<Debt> debts = snapshot.data!;
          if (_filteredDebtType != getAppLocalizations(context)!.all) {
            debts.removeWhere((element) =>
                element.debtType.localized(context) != _filteredDebtType!);
          }
          if (debts.isEmpty) {
            return _createNoDebtsWidget();
          }
          return SingleChildScrollView(
            child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => debts[index]
                    .createDisplayWidget(context, () => setState(() {})),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: debts.length),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _filteredDebtType ??= getAppLocalizations(context)!.all;
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.debts),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _createDebtTypeRadios(),
            _createDebtListWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DebtFormPage(null),
              ));
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
