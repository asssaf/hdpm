import 'package:flutter/material.dart';
import 'package:hdpm/models/appstate.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('AppStateContainer');

class AppStateContainer extends StatefulWidget {
  AppStateContainer({
    @required this.child,
    this.state,
  });

  final AppState state;
  final Widget child;

  @override
  State createState() => _AppStateContainerState();

  static _AppStateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer) as _InheritedStateContainer).data;
  }
}

class _AppStateContainerState extends State<AppStateContainer> {
  AppState state;

  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = AppState();
    }
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final _AppStateContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
