import 'package:bs_flutter/application.dart';
import 'package:bs_flutter/app/di/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'hive_registrar.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapters();
  await setupServiceLocator();

  if (kReleaseMode) {
    await SentryFlutter.init((options) {
      options.dsn = 'https://d5dbaa502a559be188b80989244146f8@o4510867834732544.ingest.us.sentry.io/4510867835781120';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    }, appRunner: () => runApp(const BillSplitterApplication()));
  } else {
    runApp(const BillSplitterApplication());
  }
}
