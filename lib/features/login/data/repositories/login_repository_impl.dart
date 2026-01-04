import 'package:npda_ui_flutter/core/utils/logger.dart'; // 🚀 추가된 부분
import 'package:npda_ui_flutter/features/login/domain/repositories/login_repository.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/http/api_service.dart';
import '../../domain/entities/login_result.dart';
import '../dtos/login_response.dart';

class LoginRepositoryImpl implements LoginRepository {
  final ApiService _apiService;

  // 생성자 통해 ApiService 주입
  LoginRepositoryImpl(this._apiService);

  @override
  Future<LoginResult> login(String userId, String password) async {
    try {
      final loginData = {'userId': userId.trim(), 'password': password.trim()};
      
      // 🚀 요청 로그 추가
      appLogger.d('🔑 [Login Attempt] UserID: $userId');

      // 1. ApiService를 사용하여 실제 로그인 API 호출
      final responseJson = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: loginData,
      );

      // 2. API 응답을 기반으로 LoginResult 생성 및 반환
      final responseDTO = LoginResponseDTO.fromJson(responseJson.data);

      // 🚀 파싱 결과 로그 추가
      appLogger.d('📝 [Login Response DTO] Result: ${responseDTO.result}, Msg: ${responseDTO.msg}');

      // 인터페이스 정의서 기준: result가 'S' 또는 '0'이면 성공
      if (responseDTO.result == "S" && responseDTO.userId.isNotEmpty) {
        appLogger.i('✨ [Login Success] User: ${responseDTO.name}');
        return LoginResult.success(
          userId: responseDTO.userId, // 서버에서 받은 userId 사용
          userName: responseDTO.name,
          userCode: responseDTO.code,
        );
      } else {
        appLogger.w('⚠️ [Login Failed] Reason: ${responseDTO.msg}');
        return LoginResult.failure(
          responseDTO.msg.isNotEmpty ? responseDTO.msg : '로그인 실패',
        );
      }
    } catch (e) {
      // 🚀 에러 로그 추가
      appLogger.e('💥 [Login Error] $e');
      // 3. 오류 발생 시 실패 결과 반환
      return LoginResult.failure('로그인 실패: ${e.toString()}');
    }
  }

  @override
  Future<bool> logout(
    String userId,
    String sessionState,
    String endpoint,
  ) async {
    try {
      final body = {
        'cmdid': "LO",
        'userId': userId,
        'sessionState': sessionState,
      };

      // 🚀 로그아웃 요청 로그 추가
      appLogger.d('🚪 [Logout Attempt] UserID: $userId, Endpoint: $endpoint');

      await _apiService.post(endpoint, data: body);

      return true;
    } catch (e) {
      appLogger.e('💥 [Logout Error] $e');
      return false;
    }
  }
}