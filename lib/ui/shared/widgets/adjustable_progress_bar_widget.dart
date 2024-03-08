import 'package:finman/ui/shared/localization.dart';
import 'package:finman/ui/shared/widgets/styled_button_widget.dart';
import 'package:finman/ui/shared/widgets/styled_progress_bar_widget.dart';
import 'package:flutter/material.dart';

class AdjustableProgressBarWidget extends StatefulWidget {
  final Widget? center;
  final double lineHeight;
  final double filledPercentage;
  final Function() onMin;
  final Function() onMax;
  final Function(double value) onTweak;

  const AdjustableProgressBarWidget(
      {super.key,
      this.center,
      required this.filledPercentage,
      required this.lineHeight,
      required this.onMin,
      required this.onMax,
      required this.onTweak});

  @override
  State<StatefulWidget> createState() => AdjustableProgressBarState();
}

class AdjustableProgressBarState extends State<AdjustableProgressBarWidget> {
  Widget _createButton(String text, Function() onPressed) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: SizedBox(
          height: 35,
          child: StyledButtonWidget(text: text, onPressed: onPressed),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StyledProgressBarWidget(
            filledPercentage: widget.filledPercentage,
            lineHeight: widget.lineHeight,
            center: widget.center),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createButton(getAppLocalizations(context)!.min, () {
              widget.onMin();
              setState(() {});
            }),
            _createButton("-\$10", () {
              widget.onTweak(-10);
              setState(() {});
            }),
            _createButton("-\$1", () {
              widget.onTweak(-1);
              setState(() {});
            }),
            const Spacer(),
            _createButton("+\$1", () {
              widget.onTweak(1);
              setState(() {});
            }),
            _createButton("+\$10", () {
              widget.onTweak(10);
              setState(() {});
            }),
            _createButton(getAppLocalizations(context)!.max, () {
              widget.onMax();
              setState(() {});
            }),
          ],
        )
      ],
    );
  }
}
