import 'package:flutter/material.dart';
import 'package:hdpm/routes.dart';

class AppBarBuilder {
  AppBar build({BuildContext context, String title, bool locked = false}) {
    final actions = <Widget>[];
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
