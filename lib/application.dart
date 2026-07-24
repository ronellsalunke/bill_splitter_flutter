import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/theme/theme_cubit.dart';
import 'package:bs_flutter/app/bloc/theme/theme_state.dart';
import 'package:bs_flutter/app/bloc/update/update_cubit.dart';
import 'package:bs_flutter/app/di/service_locator.dart';
import 'package:bs_flutter/app/routes/router.dart';
import 'package:bs_flutter/app/theme/app_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_actions/quick_actions.dart';

const _newBillShortcutType = 'new_bill_shortcut';

class BillSplitterApplication extends StatefulWidget {
  const BillSplitterApplication({super.key});

  @override
  State<BillSplitterApplication> createState() => _BillSplitterApplicationState();
}

class _BillSplitterApplicationState extends State<BillSplitterApplication> with WidgetsBindingObserver {
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<BillBloc>()..add(LoadBills())),
        BlocProvider(create: (context) => getIt<PaymentPlansBloc>()),
        BlocProvider(create: (context) => getIt<UpdateCubit>()),
        BlocProvider(create: (context) => getIt<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'bill splitter',
                theme: AppTheme.buildTheme(
                  brightness: Brightness.light,
                  dynamicColors: themeState.dynamicColorEnabled,
                  dynamicColorScheme: lightDynamic,
                ),
                darkTheme: AppTheme.buildTheme(
                  brightness: Brightness.dark,
                  dynamicColors: themeState.dynamicColorEnabled,
                  dynamicColorScheme: darkDynamic,
                ),
                themeMode: themeState.themeMode,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
