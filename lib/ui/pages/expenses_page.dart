import 'package:finman/core/models/monthly_expense.dart';
import 'package:finman/core/services/monthly_expense_service.dart';
import 'package:finman/ui/pages/expense_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<StatefulWidget> createState() => ExpensesPageState();
}

class ExpensesPageState extends State<ExpensesPage> {
  DateTime _selectedDate = DateTime.now();
  List<MonthlyExpense>? _monthlyExpenses;

  Future<void> _fetchMonthlyExpenses() async {
    _monthlyExpenses = await MonthlyExpenseService().fetchAll();
  }

  Widget _createTotalMonthlyExpensesWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              getAppLocalizations(context)!.totalMonthlyExpenses,
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
            FutureBuilder(
              future: _fetchMonthlyExpenses(),
              builder: (context, snapshot) {
                if (_monthlyExpenses == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      Text(
                          getAppLocalizations(context)!.fetchingMonthlyExpenses)
                    ],
                  );
                }
                if (_monthlyExpenses!.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off),
                      Text(getAppLocalizations(context)!.noMonthlyExpenses)
                    ],
                  );
                }
                double totalMonthlyExpenses = _monthlyExpenses!.fold(
                    0.0,
                    (double total, MonthlyExpense monthlyExpense) =>
                        total + monthlyExpense.amount);
                String recordKey =
                    MonthlyExpense.createRecordKey(_selectedDate);
                double totalPaidMonthlyExpenses = _monthlyExpenses!.fold(0.0,
                    (double total, MonthlyExpense monthlyExpense) {
                  double? record = monthlyExpense.paymentRecords[recordKey];
                  if (record == null) return total;

                  return total + record;
                });
                double paidPercentage =
                    totalPaidMonthlyExpenses / totalMonthlyExpenses;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "\$${totalPaidMonthlyExpenses.toStringAsFixed(2)}/\$${totalMonthlyExpenses.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    LinearPercentIndicator(
                      animation: true,
                      lineHeight: 20.0,
                      progressColor: Colors.deepPurple,
                      percent: paidPercentage,
                      center: Text(
                        "${(paidPercentage * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
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
        IconButton(
            onPressed: () async {
              DateTime? pickedDate = await showMonthPicker(
                  context: context, initialDate: _selectedDate);
              if (pickedDate == null) return;
              setState(() {
                _selectedDate = pickedDate;
              });
            },
            disabledColor: Colors.black,
            icon: const Icon(
              Icons.calendar_month,
              color: Colors.deepPurple,
            ))
      ],
    );
  }

  Widget _createMonthlyExpenseCard(MonthlyExpense monthlyExpense) {
    double expenseAmount = monthlyExpense.amount;
    double expensePaidAmount = monthlyExpense.getPaymentRecord(_selectedDate);
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        semanticContainer: true,
        elevation: 2.0,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExpenseFormPage(monthlyExpense, _selectedDate),
                ));
            setState(() {});
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 0,
                child: Text(
                  monthlyExpense.id,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Text(
                  "\$${monthlyExpense.amount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              LinearPercentIndicator(
                animation: true,
                lineHeight: 20,
                progressColor: Colors.deepPurple,
                percent: expensePaidAmount / expenseAmount,
                center: Text(
                  "\$${expensePaidAmount.toStringAsFixed(2)}/\$${expenseAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (!monthlyExpense.isPaid(_selectedDate)) {
                          monthlyExpense.setPaid(_selectedDate);
                        } else {
                          monthlyExpense.setUnpaid(_selectedDate);
                        }
                      });
                    },
                    child: Text(
                      monthlyExpense.isPaid(_selectedDate)
                          ? getAppLocalizations(context)!.clear
                          : getAppLocalizations(context)!.payAll,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _createExpenseListWidget() {
    return FutureBuilder(
      future: _fetchMonthlyExpenses(),
      builder: (context, snapshot) {
        if (_monthlyExpenses == null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              Text(getAppLocalizations(context)!.fetchingMonthlyExpenses)
            ],
          );
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          shrinkWrap: true,
          itemCount: _monthlyExpenses!.length,
          itemBuilder: (context, index) =>
              _createMonthlyExpenseCard(_monthlyExpenses![index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.monthlyExpenses),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpenseFormPage(null, _selectedDate),
              ));
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _createTotalMonthlyExpensesWidget()),
            const SizedBox(height: 10),
            _createDateSelectorWidget(),
            Expanded(child: _createExpenseListWidget())
          ],
        ),
      ),
    );
  }
}
