// Dio Provider

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import 'api_service.dart';
import 'api_service_impl.dart';

final dioProvider = Provider<Dio>((ref) {
  // 2. Dio 생성 시 BaseOptions 설정
  final options = BaseOptions(
    baseUrl: ApiConfig.baseUrl, //ApiConfig 에서 baseUrl 가져오기
    connectTimeout: const Duration(seconds: 60), // 연결 타임아웃 설정
    receiveTimeout: const Duration(seconds: 60), // 응답 타임아웃 설정
  );
  final dio = Dio(options);

  return dio;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  // baserUrl 설정된 dio 인스턴스 주입
  final dio = ref.watch(dioProvider);

  return ApiServiceImpl(dio);
});
