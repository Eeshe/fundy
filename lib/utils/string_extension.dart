extension StringExtension on String {
  bool isNumeric() {
    return !RegExp(r'[A-Za-z,]+').hasMatch(this);
  }

  String capitalize() {
    return substring(0, 1).toUpperCase() + substring(1);
  }
}
