import 'package:npda_ui_flutter/core/utils/logger.dart';
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
      // 1. ApiService를 사용하여 실제 로그인 API 호출

      logger(
        '======================= LoginRepositoryImpl 호출됨 =======================',
      );
      final responseJson = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {'userId': userId.trim(), 'password': password.trim()},
      );

      logger("======================== 로그인 API 응답 ========================");

      // 2. API 응답을 기반으로 LoginResult 생성 및 반환
      final responseDTO = LoginResponseDTO.fromJson(responseJson.data);

      logger("======================== 변환완료 ========================");
      logger(responseDTO.toString());

      if (responseDTO.result == "S" && responseDTO.status == "200") {
        return LoginResult.success(
          userId: userId,
          userName: responseDTO.userName,
          userCode: responseDTO.userCode, // 🚀 추가: userCode 전달
        );
      } else {
        return LoginResult.failure(responseDTO.msg);
      }
    } catch (e) {
      // 3. 오류 발생 시 실패 결과 반환
      return LoginResult.failure('로그인 실패. ${e.toString()}');
    }
  }
}
