import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:flutter_dex/data/network/logging_interceptor.dart';

class DioSingleton {
  static final DioSingleton _singleton = DioSingleton._internal();
  late final Dio _dio;

  factory DioSingleton() {
    return _singleton;
  }

  DioSingleton._internal() {
    _dio = Dio(BaseOptions(connectTimeout: const Duration(minutes: 2), receiveTimeout: const Duration(minutes: 2)));
    _dio.interceptors.add(
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
  }

  Dio get dio => _dio;
}
