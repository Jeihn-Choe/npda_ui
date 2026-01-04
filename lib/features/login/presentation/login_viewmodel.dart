import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';
import 'package:npda_ui_flutter/features/login/presentation/state/login_state.dart';

// Login 관련 Viewmodel에서 관리하는 상태들 모음

class LoginViewModel extends StateNotifier<LoginState> {
  /// SessionManager 주입 (로그인 로직 위임)
  final SessionManagerNotifier _sessionManager;

  /// controller 선언해줌.
  final TextEditingController _userIdController = TextEditingController(
    text: 'admin01',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'myrobot10!',
  );

  LoginViewModel(this._sessionManager) : super(LoginState());

  /// getter 써서 접근 가능하게 해줌 => 외부에서 controller 직접 접근 가능하도록 함.

  TextEditingController get userIdController => _userIdController;

  TextEditingController get passwordController => _passwordController;

  void disposeControllers() {
    _userIdController.dispose();
    _passwordController.dispose();
  }

  /// 로그인 시도 - SessionManager에 위임
  Future<void> login(
    BuildContext context,
    String userId,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // SessionManager에 로그인 로직 위임
      final result = await _sessionManager.login(userId, password);

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        // 라우팅은 router.dart의 redirect가 자동으로 처리
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.',
      );
    }
  }

  /// 로그아웃 - SessionManager에 위임
  void logout() {
    _sessionManager.logout();
  }
}
