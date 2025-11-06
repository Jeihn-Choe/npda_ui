import 'package:npda_ui_flutter/features/login/domain/entities/login_result.dart';
import 'package:npda_ui_flutter/features/login/domain/repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository _repository;

  LoginUseCase(this._repository);

  Future<LoginResult> call(String userId, String password) async {
    if (userId.trim().isEmpty || password.trim().isEmpty) {
      return LoginResult.failure('아이디와 비밀번호를 모두 입력해주세요.');
    }

    return await _repository.login(userId, password);
  }
}
