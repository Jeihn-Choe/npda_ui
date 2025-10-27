// lib/features/login/data/repositories/login_repository_mock.dart

import 'package:npda_ui_flutter/features/login/domain/entities/login_result.dart';
import 'package:npda_ui_flutter/features/login/domain/repositories/login_repository.dart';

// 🚀 LoginRepository의 목(Mock) 구현체
class LoginRepositoryMock implements LoginRepository {
  @override
  Future<LoginResult> login(String userId, String password) async {
    // 네트워크 지연을 시뮬레이션하기 위한 딜레이
    await Future.delayed(const Duration(seconds: 1));

    // 이 아이디만 가능하도록
    if (userId == 'test' && password == '1234') {
      return LoginResult.success(
        userId: 'CM0124456',
        userName: '테스트', // 성공 시 사용자 이름
        userCode: 1, // 성공 시 사용자 코드
      );
    } else if (userId == 'fail' || password == 'fail') {
      // 기존 실패 시뮬레이션 유지
      return LoginResult.failure('Mock: 로그인 실패 (잘못된 아이디 또는 비밀번호)');
    } else {
      // 그 외의 모든 경우는 실패 처리
      return LoginResult.failure('Mock: 아이디 또는 비밀번호가 일치하지 않습니다.');
    }
  }
}
