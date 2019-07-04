import 'package:flutter/material.dart';
import 'package:hdpm/routes.dart';

class AppBarBuilder {
  List<Widget> _actions = List();

  AppBarBuilder action(Widget action) {
    _actions.add(action);
    return this;
  }

  AppBar build({BuildContext context, String title, bool locked = false}) {
    final List<Widget> actions = List.from(_actions);
    if (!locked) {
      actions.add(buildLockAction(context));
    }

    return AppBar(
      title: Text(title),
      actions: actions,
    );
  }

  Widget buildLockAction(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.lock),
      onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.initial,
            (_) => false,
          ),
    );
  }
}
