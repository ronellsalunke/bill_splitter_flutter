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
import 'package:quick_actions/quick_actions.dart';

import 'hive_registrar.g.dart';

const _newBillShortcutType = 'new_bill_shortcut';

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final QuickActions _quickActions = const QuickActions();
  DateTime? _lastShortcutHandledAt;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeQuickActions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
  }

  Future<void> _initializeQuickActions() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    await _quickActions.initialize((type) {
      if (type != _newBillShortcutType) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNewBillFromShortcut(fromBackground: _appLifecycleState != AppLifecycleState.resumed);
      });
    });

    await _quickActions.setShortcutItems([
      const ShortcutItem(type: _newBillShortcutType, localizedTitle: 'New Bill', icon: 'ic_add'),
    ]);
  }

  void _openNewBillFromShortcut({required bool fromBackground}) {
    final now = DateTime.now();
    final lastHandledAt = _lastShortcutHandledAt;

    if (fromBackground && lastHandledAt != null && now.difference(lastHandledAt) < const Duration(seconds: 2)) {
      return;
    }

    if (lastHandledAt != null && now.difference(lastHandledAt) < const Duration(milliseconds: 900)) {
      return;
    }

    final currentConfig = router.routerDelegate.currentConfiguration;
    final currentPath = currentConfig.matches.isNotEmpty ? currentConfig.matches.last.matchedLocation : currentConfig.uri.path;

    if (currentPath.startsWith('/bill/')) {
      return;
    }

    _lastShortcutHandledAt = now;
    router.pushNamed('bill', pathParameters: {'id': 'new'});
  }

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
