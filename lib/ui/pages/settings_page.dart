import 'package:finman/core/providers/settings_provider.dart';
import 'package:finman/ui/pages/color_picker_dialog.dart';
import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/scrollable_page_widget.dart';
import 'package:finman/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextStyle _mainSettingLabel = const TextStyle(fontSize: 30);
  final TextStyle _subSettingLabel = const TextStyle(fontSize: 24);
  final TextStyle _colorSettingLabel = const TextStyle(fontSize: 20);

  @override
  void initState() {
    super.initState();
  }

  Widget _createAppThemeRadio(ThemeMode themeMode) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Row(
          children: [
            Radio(
                value: themeMode,
                groupValue: settingsProvider.fetchThemeMode(),
                onChanged: (value) {
                  settingsProvider.saveThemeMode(themeMode);
                }),
            Text(themeMode.name.capitalize())
          ],
        );
      },
    );
  }

  List<Widget> _createAppThemeWidgets() {
    List<Widget> radios = [];
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

  Widget _createColorsWidgets() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        ThemeMode themeMode = settingsProvider.fetchThemeMode();
        if (themeMode == ThemeMode.system) return const SizedBox();

        return Column(
          children: [
            Text(
              getAppLocalizations(context)!.colorSettings,
              style: _subSettingLabel,
            ),
            _createColorWidget(getAppLocalizations(context)!.backgroundColor,
                settingsProvider.fetchBackgroundColor(themeMode), (color) {
              settingsProvider.saveBackgroundColor(color, themeMode);
            }),
            _createColorWidget(getAppLocalizations(context)!.primaryColor,
                settingsProvider.fetchPrimaryColor(themeMode), (color) {
              settingsProvider.savePrimaryColor(color, themeMode);
            }),
            _createColorWidget(getAppLocalizations(context)!.positiveColor,
                settingsProvider.fetchPositiveColor(themeMode), (color) {
              settingsProvider.savePositiveColor(color, themeMode);
            }),
            _createColorWidget(getAppLocalizations(context)!.negativeColor,
                settingsProvider.fetchNegativeColor(themeMode), (color) {
              settingsProvider.saveNegativeColor(color, themeMode);
            })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                ..._createAppThemeWidgets(), _createColorsWidgets()],
            ),
          ),
        );
  }
}
