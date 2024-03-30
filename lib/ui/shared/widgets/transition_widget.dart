import 'package:flutter/material.dart';

Route createTransitionRoute(Widget destinationWidget, Offset startingPoint) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destinationWidget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const endingPoint = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: startingPoint, end: endingPoint)
          .chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
