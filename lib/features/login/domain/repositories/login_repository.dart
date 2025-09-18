import 'package:npda_ui_flutter/features/login/domain/entities/login_result.dart';

abstract class LoginRepository {
  Future<LoginResult> login(String username, String password);
}
