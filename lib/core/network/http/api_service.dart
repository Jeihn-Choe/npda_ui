// lib/core/network/http/api_service.dart

abstract class ApiService {
  /// GET 요청
  /// [path] - 요청 경로 (예: '/users')
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});

  /// POST 요청
  /// [path] - 요청 경로
  /// [data] - 요청 본문(body)에 해당
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  /// PUT 요청
  /// [path] - 요청 경로
  /// [data] - 요청 본문(body)에 해당
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  /// DELETE 요청
  /// [path] - 요청 경로
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
}