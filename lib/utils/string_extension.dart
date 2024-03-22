extension StringExtension on String {
  bool isScientificNotation() {
    final regex = RegExp(r'^[-+]?\d+(\.\d*)?[eE][-+]?\d+$');
    return regex.hasMatch(this);
  }

  bool isNumeric() {
    if (isScientificNotation()) return true;

    return !RegExp(r'[A-Za-z,]+').hasMatch(this);
  }

  String capitalize() {
    return substring(0, 1).toUpperCase() + substring(1);
  }
}
