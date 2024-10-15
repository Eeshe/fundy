import 'package:fundy/utils/hex_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late final SharedPreferences preferences;

  Future<void> initializeSettings() async {
    preferences = await SharedPreferences.getInstance();
  }

  ThemeMode fetchThemeMode() {
    String? themeId = preferences.getString("theme");
    themeId ??= ThemeMode.dark.name;

    return ThemeMode.values.firstWhere((element) => element.name == themeId);
  }

  void saveThemeMode(ThemeMode themeMode) async {
    (await SharedPreferences.getInstance()).setString("theme", themeMode.name);
    notifyListeners();
  }

  Color _fetchColor(String path, ThemeMode themeMode, Color defaultColor) {
    String? hexString =
        preferences.getString("themeColors.${themeMode.name}.$path");
    hexString ??= defaultColor.toHex();

    return HexColor.fromHex(hexString);
  }

  Color fetchBackgroundColor(ThemeMode themeMode) {
    return _fetchColor("backgroundColor", themeMode,
        themeMode == ThemeMode.light ? Colors.white : Colors.black);
  }

  Color fetchPrimaryColor(ThemeMode themeMode) {
    return _fetchColor("primaryColor", themeMode,
        themeMode == ThemeMode.light ? Colors.lightBlue : Colors.purple);
  }

  Color fetchPositiveColor(ThemeMode themeMode) {
    return _fetchColor("positiveColor", themeMode, Colors.green);
  }

  Color fetchNegativeColor(ThemeMode themeMode) {
    return _fetchColor("negativeColor", themeMode, Colors.red);
  }

  Future<void> _setColor(String path, ThemeMode themeMode, Color color) async {
    (await SharedPreferences.getInstance()).setString("themeColors.${themeMode.name}.$path", color.toHex());
    notifyListeners();
  }

  void saveBackgroundColor(Color color, ThemeMode themeMode) {
    _setColor("backgroundColor", themeMode, color);
  }

  void savePrimaryColor(Color color, ThemeMode themeMode) {
    _setColor("primaryColor", themeMode, color);
  }

  void saveAccentColor(Color color, ThemeMode themeMode) {
    _setColor("accentColor", themeMode, color);
  }

  void savePositiveColor(Color color, ThemeMode themeMode) {
    _setColor("positiveColor", themeMode, color);
  }

  void saveNegativeColor(Color color, ThemeMode themeMode) {
    _setColor("negativeColor", themeMode, color);
  }

  String fetchLocale() {
    return preferences.getString("locale") ?? "en";
  }

  void saveLocale(String locale) {
    preferences.setString("locale", locale);
    notifyListeners();
  }
}