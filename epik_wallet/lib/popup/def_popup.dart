import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefPopup extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 300);
  Widget child;

  EdgeInsets edgeInsets;

  DefPopup({@required this.child, this.edgeInsets});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Card(
      child: child,
      elevation: 4,
      margin: edgeInsets,
    );
  }

  @override
  Duration get transitionDuration => _duration;
}
