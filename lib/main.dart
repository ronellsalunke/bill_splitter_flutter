import 'package:bs_flutter/app/routes/router.dart';
import 'package:bs_flutter/app/res/app_colors.dart';
import 'package:bs_flutter/app/bloc/app_bloc.dart';
import 'package:bs_flutter/app/bloc/app_event.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/bill_bloc/bill_event.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'hive_registrar.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapters();
  final billBox = await Hive.openBox<Bill>('bills');
  runApp(MyApp(billBox: billBox));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.billBox});

  final Box<Bill> billBox;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppBloc()..add(AppStarted())),
        BlocProvider(create: (context) => BillBloc(billBox)..add(LoadBills())),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'bill Splitter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'jetbrains_mono',
          scaffoldBackgroundColor: AppColors.backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            centerTitle: true,
            scrolledUnderElevation: 0,
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
