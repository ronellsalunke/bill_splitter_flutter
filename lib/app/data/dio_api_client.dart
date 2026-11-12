import 'dart:convert';
import 'dart:io';

import 'package:bs_flutter/app/data/api_client.dart';
import 'package:bs_flutter/app/data/api_failure.dart';
import 'package:dio/dio.dart';

class DioApiClient implements ApiClient {
  DioApiClient(this._dio);

  final Dio _dio;

  @override
  Future<dynamic> getJson(String url) async {
    try {
      final response = await _dio.get<dynamic>(url);
      return _decode(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on ApiFailure {
      rethrow;
    } on FormatException catch (error) {
      throw ApiFailure(ApiFailureKind.parsing, error.message);
    } catch (error) {
      throw ApiFailure(ApiFailureKind.unknown, error.toString());
    }
  }

  @override
  Future<dynamic> postJson(String url, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post<dynamic>(url, data: data);
      return _decode(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on ApiFailure {
      rethrow;
    } on FormatException catch (error) {
      throw ApiFailure(ApiFailureKind.parsing, error.message);
    } catch (error) {
      throw ApiFailure(ApiFailureKind.unknown, error.toString());
    }
  }

  @override
  Future<dynamic> uploadFile(String url, {required String field, required File file, String? filename}) async {
    try {
      final multipartFile = await MultipartFile.fromFile(file.path, filename: filename);
      final response = await _dio.post<dynamic>(url, data: FormData.fromMap({field: multipartFile}));
      return _decode(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on ApiFailure {
      rethrow;
    } on FormatException catch (error) {
      throw ApiFailure(ApiFailureKind.parsing, error.message);
    } catch (error) {
      throw ApiFailure(ApiFailureKind.unknown, error.toString());
    }
  }

  dynamic _decode(dynamic data) {
    if (data is! String) return data;

    try {
      return jsonDecode(data);
    } on FormatException catch (error) {
      throw ApiFailure(ApiFailureKind.parsing, error.message);
    }
  }

  ApiFailure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ApiFailure(ApiFailureKind.timeout, error.message ?? 'Request timed out'),
      DioExceptionType.badResponse => ApiFailure(
        ApiFailureKind.badStatus,
        _badResponseMessage(error.response),
        error.response?.statusCode,
      ),
      DioExceptionType.connectionError => ApiFailure(ApiFailureKind.network, error.message ?? 'Network request failed'),
      DioExceptionType.badCertificate => ApiFailure(ApiFailureKind.unknown, error.message ?? 'Certificate verification failed'),
      DioExceptionType.cancel => ApiFailure(ApiFailureKind.unknown, error.message ?? 'Request cancelled'),
      DioExceptionType.unknown => ApiFailure(ApiFailureKind.unknown, error.message ?? 'Unknown API error'),
      _ => ApiFailure(ApiFailureKind.unknown, error.message ?? 'Unknown API error'),
    };
  }

  String _badResponseMessage(Response<dynamic>? response) {
    final body = response?.data;
    if (body case {'message': final Object message}) {
      final text = message.toString().trim();
      if (text.isNotEmpty && text.length <= 200) return text;
    }
    return response?.statusMessage ?? 'Request failed';
  }
}
