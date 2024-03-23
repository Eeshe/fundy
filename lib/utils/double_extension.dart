extension DoubleExtension on double {
  String format() {
    final formattedValue = toStringAsFixed(2);
    final parts = formattedValue.split('.');
    final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    final decPart = parts[1];

    return '$intPart.$decPart';
  }
}
