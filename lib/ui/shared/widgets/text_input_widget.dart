import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final TextEditingController inputController;
  final String hintText;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;

  const TextInputWidget(
      {super.key,
      required this.inputController,
      required this.hintText,
      this.textInputType,
      required this.validator,
      this.onChanged});

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
        errorMaxLines: 2),
      keyboardType: widget.textInputType,
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
