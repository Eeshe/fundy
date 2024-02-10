import 'package:finman/core/models/saving.dart';
import 'package:finman/core/services/saving_service.dart';
import 'package:finman/ui/pages/saving_form_page.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:flutter/material.dart';

class SavingListPage extends StatefulWidget {
  const SavingListPage({super.key});

  @override
  State<StatefulWidget> createState() => SavingListPageState();
}

class SavingListPageState extends State<SavingListPage> {
  Widget _createErrorWidget() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          Text(
            getAppLocalizations(context)!.savingFetchingError,
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
          getAppLocalizations(context)!.fetchingSavings,
          style: const TextStyle(fontSize: 36),
        )
      ],
    );
  }

  Widget _createNoSavingsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.search_off,
          color: Colors.red,
        ),
        Text(
          getAppLocalizations(context)!.noSavingsFound,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36),
        ),
        Text(
          getAppLocalizations(context)!.createSavingInstruction,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        )
      ],
    );
  }

  Widget _createSavingListWidget() {
    return FutureBuilder(
        future: SavingService().fetchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _createLoadingWidget();
          } else if (snapshot.hasError) {
            return _createErrorWidget();
          }
          List<Saving> savings = snapshot.data!;
          if (savings.isEmpty) {
            return _createNoSavingsWidget();
          }
          return SingleChildScrollView(
            child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    savings[index].createDisplayWidget(() => setState(() {})),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: savings.length),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppLocalizations(context)!.savings),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _createSavingListWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavingFormPage(null),
              ));
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
