import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StyledProgressBarWidget extends StatelessWidget {
  final Widget? center;
  final double lineHeight;
  final double filledPercentage;

  const StyledProgressBarWidget(
      {super.key,
      required this.filledPercentage,
      required this.lineHeight,
      this.center});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: LinearPercentIndicator(
        padding: EdgeInsets.zero,
        animation: true,
        animateFromLastPercent: true,
        barRadius: const Radius.circular(2),
        lineHeight: lineHeight,
        progressColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.background,
        percent: filledPercentage,
        center: center,
      ),
    );
  }
}
