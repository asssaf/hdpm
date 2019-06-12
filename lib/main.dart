import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hdpm/appstatecontainer.dart';
import 'package:hdpm/routes.dart';
import 'package:logging/logging.dart';

void initLogging() {
  Logger.root.level = Level.WARNING;

  // set level for debug mode only
  if (!kReleaseMode) {
    Logger.root.level = Level.ALL;
  }

  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint('${rec.level.name} ${rec.time} ${rec.loggerName} - ${rec.message}');
  });
}

void main() {
  initLogging();
  runApp(AppStateContainer(child: HdpmApp()));
}

class HdpmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hdpm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
