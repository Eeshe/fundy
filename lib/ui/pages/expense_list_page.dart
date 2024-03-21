import 'package:finman/core/models/monthly_expense.dart';
import 'package:finman/core/services/monthly_expense_service.dart';
import 'package:finman/ui/pages/expense_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/empty_list_widget.dart';
import 'package:finman/ui/shared/widgets/styled_progress_bar_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<StatefulWidget> createState() => ExpenseListPageState();
}

class ExpenseListPageState extends State<ExpenseListPage> {
  DateTime _selectedDate = DateTime.now();
  List<MonthlyExpense>? _monthlyExpenses;

  Future<void> _fetchMonthlyExpenses() async {
    _monthlyExpenses = await MonthlyExpenseService().fetchAll();
  }

  Widget _createTotalMonthlyExpensesWidget() {
    if (_monthlyExpenses == null || _monthlyExpenses!.isEmpty) {
      return const SizedBox();
    }

    double totalMonthlyExpenses = 0;
    double totalPaidMonthlyExpenses = 0;
    String recordKey = MonthlyExpense.createRecordKey(_selectedDate);
    for (MonthlyExpense monthlyExpense in _monthlyExpenses!) {
      totalMonthlyExpenses += monthlyExpense.amount;
      if (!monthlyExpense.paymentRecords.containsKey(recordKey)) continue;

      totalPaidMonthlyExpenses += monthlyExpense.paymentRecords[recordKey]!;
    }
    double filledPercentage = totalPaidMonthlyExpenses / totalMonthlyExpenses;
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "\$${totalPaidMonthlyExpenses.format()}/\$${totalMonthlyExpenses.format()}",
            style: const TextStyle(fontSize: 24),
          ),
          StyledProgressBarWidget(
              center: Text(
                "${(filledPercentage * 100).format()}%",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              filledPercentage: filledPercentage,
            lineHeight: 25,
            boxDecoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.background,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          )
        ],
      ),
    );
  }

  Widget _createDateSelectorWidget() {
    String locale = Localizations.localeOf(context).languageCode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${DateFormat.MMMM(locale).format(_selectedDate).capitalize()} ${_selectedDate.year}",
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        SizedBox(
          height: 30,
          child: IconButton(
            iconSize: 30,
            padding: EdgeInsets.zero,
            onPressed: () async {
              DateTime? pickedDate = await showMonthPicker(
                  selectedMonthTextColor:
                      Theme.of(context).colorScheme.onBackground,
                  selectedMonthBackgroundColor:
                      Theme.of(context).colorScheme.primary,
                  currentMonthTextColor:
                      Theme.of(context).colorScheme.onBackground,
                  context: context,
                  initialDate: _selectedDate);
              if (pickedDate == null) return;
              setState(() {
                _selectedDate = pickedDate;
              });
            },
            disabledColor: Colors.white,
            icon: Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        )
      ],
    );
  }

  ElevatedButton _createNewExpenseButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseFormPage(null, _selectedDate),
            ));
        setState(() {});
      },
      child: Text(
        getAppLocalizations(context)!.newText,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }

  Widget _createExpenseListWidget() {
    if (_monthlyExpenses!.isEmpty) {
      return EmptyListWidget(
        title: getAppLocalizations(context)!.noMonthlyExpenses,
        subtitle: getAppLocalizations(context)!.createSavingInstruction,
      );
    }
    return ListView.separated(
        itemBuilder: (context, index) => _monthlyExpenses![index]
            .createListWidget(context, _selectedDate, () => setState(() {})),
        separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
        itemCount: _monthlyExpenses!.length);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchMonthlyExpenses(),
      builder: (context, snapshot) {
        if (_monthlyExpenses == null) return const SizedBox();
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(getAppLocalizations(context)!.monthlyExpenses),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _createTotalMonthlyExpensesWidget(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _createDateSelectorWidget(),
                      _createNewExpenseButton(),
                      Expanded(child: _createExpenseListWidget())
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
