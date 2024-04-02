import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final TextEditingController inputController;
  final String hintText;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final FocusNode? focusNode;

  const TextInputWidget(
      {super.key,
      required this.inputController,
      required this.hintText,
      this.textInputType,
      this.validator,
      this.onChanged,
      this.textAlign = TextAlign.start,
      this.textStyle,
      this.focusNode});

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
      textAlign: widget.textAlign,
      style: widget.textStyle,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textCapitalization: TextCapitalization.sentences,
      focusNode: widget.focusNode,
    );
  }
}
