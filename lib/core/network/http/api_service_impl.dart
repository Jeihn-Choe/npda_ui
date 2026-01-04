import 'package:dio/dio.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart'; // 🚀 추가된 부분

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
      // 🚀 요청 로그 추가
      appLogger.d('🌐 [GET] Request: $path, Params: $queryParameters');
      
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // 🚀 요청 로그 추가
      appLogger.d('🌐 [POST] Request: $path, Data: $data, Params: $queryParameters');

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // 🚀 요청 로그 추가
      appLogger.d('🌐 [PUT] Request: $path, Data: $data, Params: $queryParameters');

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // 🚀 요청 로그 추가
      appLogger.d('🌐 [DELETE] Request: $path, Data: $data, Params: $queryParameters');

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleException(e);
    }
  }

  dynamic _handleResponse(Response response) {
    // 🚀 응답 로그 추가
    appLogger.d('✅ [Response] Status: ${response.statusCode}, Data: ${response.data}');

    // 성공적인 응답 (2xx 상태 코드)일 경우, 데이터 본문만 반환합니다.
    if (response.statusCode != null && response.statusCode == 200) {
      return response;
    }
    throw Exception('서버 응답 오류: ${response.statusCode}');
  }

  Exception _handleException(Object error) {
    // 🚀 예외 로그 추가
    appLogger.e('❌ [API Exception] Error: $error');

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('서버 연결 시간이 초과되었습니다. 다시 시도해주세요.');
        case DioExceptionType.connectionError:
          return Exception('서버와 연결할 수 없습니다. 네트워크 연결 상태를 확인해주세요.');
        case DioExceptionType.badResponse:
          return Exception('서버 오류가 발생했습니다. (코드: ${error.response?.statusCode})');
        case DioExceptionType.cancel:
          return Exception('요청이 취소되었습니다.');
        default:
          return Exception('네트워크 오류가 발생했습니다: ${error.message}');
      }
    }
    return Exception('알 수 없는 오류가 발생했습니다: $error');
  }
}