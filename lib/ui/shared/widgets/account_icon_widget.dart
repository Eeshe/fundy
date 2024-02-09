import 'package:flutter/material.dart';

class AccountIconWidget extends StatelessWidget {
  final String iconPath;
  final double width;
  final double height;

  const AccountIconWidget(this.iconPath, this.width, this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/$iconPath'),
          )),
    );
  }
}
