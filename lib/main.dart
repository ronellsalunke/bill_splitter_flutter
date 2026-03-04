import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/theme/theme_bloc.dart';
import 'package:bs_flutter/app/bloc/theme/theme_state.dart';
import 'package:bs_flutter/app/di/service_locator.dart';
import 'package:bs_flutter/app/res/app_colors.dart';
import 'package:bs_flutter/app/routes/router.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    }, appRunner: () => runApp(const MyApp()));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _buildTheme(Brightness brightness, bool dynamicColors, ColorScheme? dynamicColorScheme) {
    ColorScheme colorScheme;

    if (dynamicColors && dynamicColorScheme != null) {
      // use dynamic colors when available
      colorScheme = dynamicColorScheme;
    } else {
      // fallback to default color scheme
      colorScheme = ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent, brightness: brightness);
    }

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'jetbrains_mono',
      scaffoldBackgroundColor: brightness == Brightness.light ? AppColors.backgroundColorLight : AppColors.backgroundColorDark,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.backgroundColorLight : AppColors.backgroundColorDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<BillBloc>()..add(LoadBills())),
        BlocProvider(create: (context) => getIt<PaymentPlansBloc>()),
        BlocProvider(create: (context) => getIt<ThemeBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'bill splitter',
                theme: _buildTheme(Brightness.light, themeState.dynamicColorEnabled, lightDynamic),
                darkTheme: _buildTheme(Brightness.dark, themeState.dynamicColorEnabled, darkDynamic),
                themeMode: themeState.currentTheme,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
