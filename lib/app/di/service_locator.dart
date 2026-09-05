import 'package:bs_flutter/app/bloc/bill_bloc/bill_bloc.dart';
import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_cubit.dart';
import 'package:bs_flutter/app/bloc/theme/theme_cubit.dart';
import 'package:bs_flutter/app/bloc/update/update_cubit.dart';
import 'package:bs_flutter/app/data/base_api_services.dart';
import 'package:bs_flutter/app/data/network_api_service.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:bs_flutter/utils/share_intent_service.dart';
import 'package:bs_flutter/utils/swipe_hint_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  final billBox = await Hive.openBox<Bill>('bills');
  getIt.registerSingleton<Box<Bill>>(billBox);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<SwipeHintPreferences>(() => SwipeHintPreferences(getIt<SharedPreferences>()));

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ),
    );
    return dio;
  });

  getIt.registerLazySingleton<BaseApiServices>(() => NetworkApiService(getIt<Dio>()));

  getIt.registerLazySingleton<AppRepository>(() => AppRepository(apiServices: getIt<BaseApiServices>()));

  final shareIntentService = ShareIntentService();
  shareIntentService.initialize();
  getIt.registerSingleton<ShareIntentService>(shareIntentService);

  getIt.registerFactory<BillBloc>(() => BillBloc(getIt<Box<Bill>>()));
  getIt.registerFactory<PaymentPlansCubit>(() => PaymentPlansCubit(getIt<AppRepository>()));
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt<SharedPreferences>()));
  getIt.registerFactory<UpdateCubit>(
    () => UpdateCubit(getIt<AppRepository>(), getIt<SharedPreferences>(), isDebugMode: kDebugMode),
  );
}
