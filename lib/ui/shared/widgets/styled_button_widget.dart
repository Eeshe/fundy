import 'package:flutter/material.dart';

class StyledButtonWidget extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool isNegativeButton;

  const StyledButtonWidget(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isNegativeButton = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: !isNegativeButton
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: onPressed,
            child: Text(text),
          ),
        )
      ],
    );
  }
}
