import 'package:dio/dio.dart';

import 'api_service.dart';

class ApiServiceImpl implements ApiService {
  final Dio _dio;

  ApiServiceImpl(this._dio);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  @override
  Future<Response> put(
    String path, {
    dynamic? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to put data: $e');
    }
  }

  @override
  Future<Response> delete(
    String path, {
    dynamic? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }


  dynamic _handleResponse(Response response) {
         // 성공적인 응답 (2xx 상태 코드)일 경우, 데이터 본문만    반환합니다.
         if (response.statusCode != null && response.statusCode== 200) {
           return response.data;

    }
