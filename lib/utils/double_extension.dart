import 'package:finman/utils/string_extension.dart';
import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String format() {
    if (toString().isScientificNotation()) return toString();

    return NumberFormat("#,###.##").format(this);
  }
}
