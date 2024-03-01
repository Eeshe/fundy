import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final TextEditingController inputController;
  final String hintText;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;

  const TextInputWidget(
      {super.key,
      required this.inputController,
      required this.hintText,
      this.textInputType,
      required this.validator});

  @override
  State<StatefulWidget> createState() => TextInputState();
}

class TextInputState extends State<TextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.inputController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        focusColor: Theme.of(context).colorScheme.primary,
      ),
      keyboardType: widget.textInputType,
      validator: widget.validator,
    );
  }
}
