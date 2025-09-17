import 'package:npda_ui_flutter/core/config/api_config.dart';
import 'package:npda_ui_flutter/core/network/http/api_service.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/login/domain/entities/login_result.dart';

class LoginUseCase {
  final ApiService _apiService;

  LoginUseCase(this._apiService);

  Future<LoginResult> call(String userId, String password) async {
    if (userId.trim().isEmpty || password.trim().isEmpty) {
      return LoginResult.failure('아이디와 비밀번호를 모두 입력해주세요.');
    }

    logger('validation 완료');

    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {'userId': userId.trim(), 'password': password.trim()},
      );

      logger('api 요청완료');

      return LoginResult.success(
        userId: userId,
        userName: response['userName'],
      );
    } catch (e) {
      return LoginResult.failure('로그인 실패. ID와 비밀번호를 확인해주세요.');
    }
  }
}
