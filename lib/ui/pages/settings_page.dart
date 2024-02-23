import 'package:finman/core/services/settings_service.dart';
import 'package:finman/main.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
      _accentColor,
      _positiveColor,
      _negativeColor;

  Future<void> _fetchStoredSettings() async {
    SettingsService settingsService = SettingsService();
    await settingsService.initializeSettings();

    _themeMode = settingsService.fetchThemeMode();
    _backgroundColor = settingsService.fetchBackgroundColor(_themeMode!);
    _primaryColor = settingsService.fetchPrimaryColor(_themeMode!);
    _accentColor = settingsService.fetchAccentColor(_themeMode!);
    _positiveColor = settingsService.fetchPositiveColor(_themeMode!);
    _negativeColor = settingsService.fetchNegativeColor(_themeMode!);
  }

  @override
  void initState() {
    super.initState();
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

  List<Widget> _createAppThemeWidget() {
    List<Row> radios = [];
    for (var themeMode in ThemeMode.values) {
      radios.add(_createAppThemeRadio(themeMode));
    }
    return radios;
  }

  Widget _createColorWidget(
      String label, Color color, Function(Color color) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _colorSettingLabel),
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SingleChildScrollView(
                    child: Material(
                      child: HueRingPicker(
                        pickerColor: color,
                        enableAlpha: true,
                        displayThumbColor: true,
                        onColorChanged: onChanged,
                      ),
                    ),
                  );
                });
          },
          child: SizedBox(
            height: 20,
            width: 200,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: color,
              ),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _createColorsWidget() {
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
          _backgroundColor = color;
        });
        SettingsService().saveBackgroundColor(color, _themeMode!);
      }),
      _createColorWidget(
          getAppLocalizations(context)!.primaryColor, _primaryColor!, (color) {
        setState(() {
          _primaryColor = color;
        });
        SettingsService().savePrimaryColor(color, _themeMode!);
      }),
      _createColorWidget(
          getAppLocalizations(context)!.accentColor, _accentColor!, (color) {
        setState(() {
          _accentColor = color;
        });
        SettingsService().saveAccentColor(color, _themeMode!);
      }),
      _createColorWidget(
          getAppLocalizations(context)!.positiveColor, _positiveColor!,
          (color) {
        setState(() {
          _positiveColor = color;
        });
        SettingsService().savePositiveColor(color, _themeMode!);
      }),
      _createColorWidget(
          getAppLocalizations(context)!.negativeColor, _negativeColor!,
          (color) {
        setState(() {
          _negativeColor = color;
        });
        SettingsService().saveNegativeColor(color, _themeMode!);
      })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchStoredSettings(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getAppLocalizations(context)!.styleSettings,
                  style: _mainSettingLabel,
                ),
                Text(
                  getAppLocalizations(context)!.themeSettings,
                  style: _subSettingLabel,
                ),
                ..._createAppThemeWidget(),
                ..._createColorsWidget()
              ],
            ),
          ),
        );
      },
    );
  }
}
