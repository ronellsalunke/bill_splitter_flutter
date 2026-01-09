import 'package:bs_flutter/app/data/app_exceptions.dart';
import 'package:bs_flutter/app/data/base_api_services.dart';
import 'package:bs_flutter/app/data/dio_singleton.dart';
import 'package:dio/dio.dart';

class NetworkApiService extends BaseApiServices {
  final Dio _dio = DioSingleton().dio;

  @override
  Future getGetApiResponse(String url) async {
    try {
      final response = await _dio.get(url);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future getPostApiResponse(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  dynamic _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        return response.data;
      case 400:
        throw BadRequestException(response.data?.toString() ?? 'Bad Request');
      case 404:
        throw UnauthorisedException(response.data?.toString() ?? 'Not Found');
      case 408:
        throw RequestTimeoutException(response.data?.toString() ?? 'Request Timeout');
      case 429:
        throw TooManyRequestsException(response.data?.toString() ?? 'Too Many Requests');
      default:
        throw FetchDataException('Error occurred while communicating with server, Status code ${response.statusCode}');
    }
  }

  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return RequestTimeoutException('Request timed out');
      case DioExceptionType.connectionError:
        return FetchDataException('No Internet Connection');
      case DioExceptionType.badResponse:
        // This should be handled in _handleResponse, but as fallback
        return FetchDataException('Server error: ${e.response?.statusCode}');
      default:
        return FetchDataException('Network error occurred');
    }
  }
}
