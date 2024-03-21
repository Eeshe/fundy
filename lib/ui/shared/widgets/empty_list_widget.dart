import 'package:flutter/material.dart';

class EmptyListWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyListWidget(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          color: Theme.of(context).colorScheme.error,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        )
      ],
    );
  }
}
