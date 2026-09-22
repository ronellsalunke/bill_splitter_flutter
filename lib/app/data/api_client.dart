import 'dart:io';

abstract class ApiClient {
  Future<dynamic> getJson(String url);

  Future<dynamic> postJson(String url, Map<String, dynamic> data);

  Future<dynamic> uploadFile(String url, {required String field, required File file, String? filename});
}
