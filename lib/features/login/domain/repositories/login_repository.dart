import 'package:npda_ui_flutter/features/login/domain/entities/login_result.dart';

abstract class LoginRepository {
  Future<LoginResult> login(String username, String password);

  /// 로그아웃 요청
  /// [userId]: 로그아웃하는 사용자 ID
  /// [endpoint]: '/user/logout' 또는 '/user/expired'
  Future<bool> logout(String userId, String sessionState, String endpoint);
}
