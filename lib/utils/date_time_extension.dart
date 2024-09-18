import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {

  String formatDayMonthYear() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String formatDayMonthYearTime() {
    return DateFormat('dd/MM/yyyy - kk:mm').format(this);
  }
}