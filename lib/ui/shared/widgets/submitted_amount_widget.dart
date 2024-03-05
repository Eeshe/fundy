import 'package:finman/ui/shared/widgets/adjustable_progress_bar_widget.dart';
import 'package:finman/ui/shared/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';

class SubmittedAmountWidget extends StatelessWidget {
  final TextEditingController submittedAmountController;
  final String submittedAmountHintText;
  final String? Function(String?)? submittedAmountValidator;

  final TextEditingController totalAmountController;
  final String totalAmountHintText;
  final String? Function(String?)? totalAmountValidator;

  const SubmittedAmountWidget(
      {super.key,
      required this.submittedAmountController,
      required this.submittedAmountHintText,
      required this.submittedAmountValidator,
      required this.totalAmountController,
      required this.totalAmountHintText,
      required this.totalAmountValidator});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextInputWidget(
            inputController: submittedAmountController,
            hintText: submittedAmountHintText,
            textInputType: const TextInputType.numberWithOptions(decimal: true),
            validator: submittedAmountValidator,
            textAlign: TextAlign.center,
            textStyle: const TextStyle(fontSize: 40),
          ),
        ),
        const Text(
          "/",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 50),
        ),
        Flexible(
          child: TextInputWidget(
            inputController: totalAmountController,
            hintText: totalAmountHintText,
            textInputType: const TextInputType.numberWithOptions(decimal: true),
            validator: totalAmountValidator,
            textAlign: TextAlign.center,
            textStyle: const TextStyle(fontSize: 40),
          ),
        ),
      ],
    );
  }
}
