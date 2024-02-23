import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/currency_type.dart';
import 'package:finman/core/models/debt.dart';
import 'package:finman/core/models/debt_type.dart';
import 'package:finman/core/models/monthly_expense.dart';
import 'package:finman/core/models/saving.dart';
import 'package:finman/core/models/transaction.dart';
import 'package:finman/core/services/account_service.dart';
import 'package:finman/core/services/conversion_service.dart';
import 'package:finman/core/services/monthly_expense_service.dart';
import 'package:finman/core/services/settings_service.dart';
import 'package:finman/ui/pages/authentication_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CurrencyTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(MonthlyExpenseAdapter());
  Hive.registerAdapter(SavingAdapter());
  Hive.registerAdapter(DebtAdapter());
  Hive.registerAdapter(DebtTypeAdapter());

  AccountService();
  ConversionService();
  MonthlyExpenseService();

  SettingsService settingsService = SettingsService();
  await settingsService.initializeSettings();

  runApp(MyApp(settingsService: settingsService));
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  final SettingsService settingsService;

  const MyApp({super.key, required this.settingsService});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    themeNotifier.value = settingsService.fetchThemeMode();
    return ValueListenableBuilder(
        valueListenable: themeNotifier,
        builder: (context, value, child) {
          ColorScheme lightColorScheme = ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.light,
              background: settingsService.fetchBackgroundColor(ThemeMode.light),
              primary: settingsService.fetchPrimaryColor(ThemeMode.light),
              secondary: settingsService.fetchAccentColor(ThemeMode.light),
              error: settingsService.fetchNegativeColor(ThemeMode.light),
              tertiary: settingsService.fetchPositiveColor(ThemeMode.light));
          ColorScheme darkColorScheme = ColorScheme.fromSeed(
              seedColor: Colors.black,
              brightness: Brightness.dark,
              background: settingsService.fetchBackgroundColor(ThemeMode.dark),
              primary: settingsService.fetchPrimaryColor(ThemeMode.dark),
              secondary: settingsService.fetchAccentColor(ThemeMode.dark),
              error: settingsService.fetchNegativeColor(ThemeMode.dark),
              tertiary: settingsService.fetchPositiveColor(ThemeMode.dark));
          return MaterialApp(
              title: 'FinMan',
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('es'),
              debugShowCheckedModeBanner: false,
              themeMode: value,
              theme:
                  ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
              darkTheme:
                  ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
              home: const AuthenticationPage());
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
