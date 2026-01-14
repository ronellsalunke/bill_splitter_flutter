import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_bloc.dart';
import 'package:bs_flutter/app/bloc/theme/theme_bloc.dart';
import 'package:bs_flutter/app/bloc/theme/theme_state.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:bs_flutter/app/res/app_colors.dart';
import 'package:bs_flutter/app/routes/router.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'hive_registrar.g.dart';
import 'utils/share_intent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapters();
  final billBox = await Hive.openBox<Bill>('bills');
  ShareIntentService.initialize();

  runApp(MyApp(billBox: billBox));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.billBox});

  final Box<Bill> billBox;

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
      colorScheme = ColorScheme.fromSeed(seedColor: Colors.white, brightness: brightness);
    }

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'jetbrains_mono',
      scaffoldBackgroundColor: brightness == Brightness.light ? AppColors.backgroundColor : Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.backgroundColor : Colors.black,
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
        BlocProvider(create: (context) => BillBloc(widget.billBox)..add(LoadBills())),
        BlocProvider(create: (context) => PaymentPlansBloc(AppRepository())),
        BlocProvider(create: (context) => ThemeBloc()),
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
