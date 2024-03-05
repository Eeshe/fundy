import 'package:flutter/material.dart';

class StyledButtonWidget extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isNegativeButton;
  final EdgeInsets padding;

  const StyledButtonWidget(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isNegativeButton = false,
      this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: !isNegativeButton
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
