import 'package:finman/core/services/settings_service.dart';
import 'package:finman/main.dart';
import 'package:finman/ui/pages/color_picker_dialog.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextStyle _mainSettingLabel = const TextStyle(fontSize: 30);
  final TextStyle _subSettingLabel = const TextStyle(fontSize: 24);
  final TextStyle _colorSettingLabel = const TextStyle(fontSize: 20);

  ThemeMode? _themeMode;
  Color? _backgroundColor,
      _primaryColor,
      _positiveColor,
      _negativeColor;

  Future<void> _fetchStoredSettings() async {
    SettingsService settingsService = SettingsService();
    await settingsService.initializeSettings();

    _themeMode = settingsService.fetchThemeMode();
    _backgroundColor = settingsService.fetchBackgroundColor(_themeMode!);
    _primaryColor = settingsService.fetchPrimaryColor(_themeMode!);
    _positiveColor = settingsService.fetchPositiveColor(_themeMode!);
    _negativeColor = settingsService.fetchNegativeColor(_themeMode!);
  }

  @override
  void initState() {
    super.initState();
  }

  void _updateTheme() {
    ThemeMode currentTheme = _themeMode!;
    if (_themeMode == ThemeMode.light) {
      MyApp.themeNotifier.value = ThemeMode.dark;
    } else {
      MyApp.themeNotifier.value = ThemeMode.light;
    }
    MyApp.themeNotifier.value = currentTheme;
  }

  Row _createAppThemeRadio(ThemeMode themeMode) {
    return Row(
      children: [
        Radio(
            value: themeMode,
            groupValue: _themeMode,
            onChanged: (value) {
              setState(() {
                _themeMode = themeMode;
              });
              SettingsService().saveThemeMode(themeMode);
              MyApp.themeNotifier.value = themeMode;
            }),
        Text(themeMode.name.capitalize())
      ],
    );
  }

  List<Widget> _createAppThemeWidgets() {
    List<Row> radios = [];
    for (var themeMode in ThemeMode.values) {
      radios.add(_createAppThemeRadio(themeMode));
    }
    return [
      Text(
        getAppLocalizations(context)!.styleSettings,
        style: _mainSettingLabel,
      ),
      Text(
        getAppLocalizations(context)!.themeSettings,
        style: _subSettingLabel,
      ),
      ...radios
    ];
  }

  Widget _createColorWidget(
      String label, Color color, Function(Color color) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _colorSettingLabel),
        InkWell(
          onTap: () async {
            await showDialog(
                context: context,
                builder: (context) => ColorPickerDialog(color, onChanged));
            _updateTheme();
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.onBackground,
                width: 0.5,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: color,
              radius: 15,
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _createColorsWidgets() {
    if (_themeMode == ThemeMode.system) return [const SizedBox()];
    return [
      Text(
        getAppLocalizations(context)!.colorSettings,
        style: _subSettingLabel,
      ),
      _createColorWidget(
          getAppLocalizations(context)!.backgroundColor, _backgroundColor!,
          (color) {
        setState(() {
          SettingsService().saveBackgroundColor(color, _themeMode!);
          _backgroundColor = color;
        });
      }),
      _createColorWidget(
          getAppLocalizations(context)!.primaryColor, _primaryColor!, (color) {
        setState(() {
          SettingsService().savePrimaryColor(color, _themeMode!);
          _primaryColor = color;
        });
      }),
      _createColorWidget(
          getAppLocalizations(context)!.positiveColor, _positiveColor!,
          (color) {
        setState(() {
          SettingsService().savePositiveColor(color, _themeMode!);
          _positiveColor = color;
        });
      }),
      _createColorWidget(
          getAppLocalizations(context)!.negativeColor, _negativeColor!,
          (color) {
        setState(() {
          SettingsService().saveNegativeColor(color, _themeMode!);
          _negativeColor = color;
        });
      })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchStoredSettings(),
      builder: (context, snapshot) {
        if (_negativeColor == null) return const SizedBox();
        return Scaffold(
          appBar: AppBar(
            title: Text(getAppLocalizations(context)!.settings),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            scrolledUnderElevation: 0,
          ),
          body: ScrollablePageWidget(
            padding:
                const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._createAppThemeWidgets(),
                ..._createColorsWidgets()
              ],
            ),
          ),
        );
      },
    );
  }
}
