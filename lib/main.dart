/// Entry point for the CodeOps desktop application.
///
/// Initializes window management, creates the Riverpod provider scope,
/// and launches the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'services/logging/log_config.dart';
import 'services/logging/log_service.dart';

/// Application entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LogConfig.initialize();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1440, 900),
    minimumSize: Size(1024, 700),
    center: true,
    title: 'CodeOps',
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  log.i('App', 'CodeOps starting');

  runApp(const ProviderScope(child: CodeOpsApp()));
}
