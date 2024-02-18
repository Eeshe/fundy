import 'package:finman/ui/shared/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'debt_type.g.dart';

@HiveType(typeId: 5)
enum DebtType {
  @HiveField(0)
  own(display: "Own"),
  @HiveField(1)
  other(display: "Other");

  const DebtType({required this.display});

  final String display;

  String localized(BuildContext context) {
    switch (this) {
      case DebtType.own:
        return getAppLocalizations(context)!.ownDebt;
      case DebtType.other:
        return getAppLocalizations(context)!.otherDebt;
    }
  }
}
