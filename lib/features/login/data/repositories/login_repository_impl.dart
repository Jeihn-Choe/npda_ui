import 'package:npda_ui_flutter/features/login/domain/repositories/login_repository.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/http/api_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/login_result.dart';
import '../dtos/login_response.dart';

class LoginRepositoryImpl implements LoginRepository {
  final ApiService _apiService;

  // 생성자 통해 ApiService 주입
  LoginRepositoryImpl(this._apiService);

  @override
  Future<LoginResult> login(String userId, String password) async {
    try {
      // 1. ApiService를 사용하여 실제 로그인 API 호출
      final responseJson = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {'userId': userId.trim(), 'password': password.trim()},
      );

      // 로그인 API 응답 확인
      appLogger.i('========== 로그인 API 응답 ==========');
      appLogger.i('응답 데이터: ${responseJson.data}');
      appLogger.i('=====================================');

      // 2. API 응답을 기반으로 LoginResult 생성 및 반환
      final responseDTO = LoginResponseDTO.fromJson(responseJson.data);

      // 인터페이스 정의서 기준: result가 'S' 또는 '0'이면 성공
      if (responseDTO.isSuccess && responseDTO.userId.isNotEmpty) {
        return LoginResult.success(
          userId: responseDTO.userId, // 서버에서 받은 userId 사용
          userName: responseDTO.name,
          userCode: responseDTO.code,
        );
      } else {
        return LoginResult.failure(
          responseDTO.msg.isNotEmpty ? responseDTO.msg : '로그인 실패',
        );
      }
    } catch (e, stackTrace) {
      // 3. 오류 발생 시 실패 결과 반환
      appLogger.e('로그인 에러 발생', error: e, stackTrace: stackTrace);
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

      await _apiService.post(endpoint, data: body);

      return true;
    } catch (e, stackTrace) {
      appLogger.e('로그아웃 에러 ($endpoint)', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
