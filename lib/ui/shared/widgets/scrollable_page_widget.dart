import 'package:flutter/material.dart';

class ScrollablePageWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const ScrollablePageWidget(
      {super.key, required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: child,
    );
  }
}
