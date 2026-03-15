import 'package:bs_flutter/app/data/base_api_services.dart';
import 'package:dio/dio.dart';

class NetworkApiService extends BaseApiServices {
  final Dio _dio;

  NetworkApiService(this._dio);

  @override
  Future getGetApiResponse(String url) async {
    final response = await _dio.get(url);
    return response.data;
  }

  @override
  Future getPostApiResponse(String url, dynamic data) async {
    final response = await _dio.post(url, data: data);
    return response.data;
  }
}
