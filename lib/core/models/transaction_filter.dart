import 'package:flutter/material.dart';
import 'package:fundy/ui/shared/localization.dart';

enum TransactionFilter {
  all,
  income,
  outcome;

  String localized(BuildContext context) {
    switch (this) {
      case TransactionFilter.all:
        return getAppLocalizations(context)!.all;
      case TransactionFilter.income:
        return getAppLocalizations(context)!.income;
      case TransactionFilter.outcome:
        return getAppLocalizations(context)!.outcome;
    }
  }
}
