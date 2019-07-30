import 'package:flutter/material.dart';
import 'package:hdpm/main.dart' show routeObserver;

/// removes the current snack bar before navigating away
/// this prevents reshowing the (now probably obsolete) snack bar when the next route is popped
class SnackBarRemover extends StatefulWidget {
  SnackBarRemover({Key key, this.child}) : super(key: key);

  final Widget child;
  @override
  State createState() => _SnackBarRemoverState();
}

class _SnackBarRemoverState extends State<SnackBarRemover> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    Scaffold.of(context).removeCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
