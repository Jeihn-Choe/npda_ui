import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/core/network/http/api_provider.dart';

import '../domain/usecase/login_usecase.dart';

// Login 관련 Viewmodel에서 관리하는 상태들 모음
class LoginState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;
  final String? userName;

  final bool isValidForm;

  const LoginState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.errorMessage,
    this.userId = 'EC31784',
    this.userName = '최제인',
    this.isValidForm = false,
  });

  LoginState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? userId,
    String? userName,
    bool? isValidForm,
  }) {
    return LoginState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isValidForm: isValidForm ?? this.isValidForm,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  /// LoginUseCase 주입
  final LoginUseCase _loginUseCase;

  /// controller 선언해줌.
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginViewModel(this._loginUseCase) : super(LoginState());

  /// getter 써서 접근 가능하게 해줌 => 외부에서 controller 직접 접근 가능하도록 함.

  TextEditingController get userIdController => _userIdController;

  TextEditingController get passwordController => _passwordController;

  void disposeControllers() {
    _userIdController.dispose();
    _passwordController.dispose();
  }

  Future<void> testLogin(
    BuildContext context,
    String userId,
    String password,
  ) async {
    state = state.copyWith(
      isLoggedIn: true,
      errorMessage: null,
      isLoading: false,
      userId: userId,
      userName: 'admin',
    );

    context.go('/inbound'); // 로그인 성공 시 이동할 경로
  }

  Future<void> login(
    BuildContext context,
    String userId,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      /// UseCase 호출
      final result = await _loginUseCase(userId, password);

      //LOG
      debugPrint('Login Result: ${result.isSuccess}');
      debugPrint('User ID: ${result.userId}');
      debugPrint('User Name: ${result.userName}');
      debugPrint('Error Message: ${result.message}');

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          userId: result.userId,
          userName: result.userName,
        );

        context.go('/inbound'); // 로그인 성공 시 이동할 경로
      } else {
        state = state.copyWith(isLoading: false, errorMessage: result.message);

        //LOG
        debugPrint('Login Result: ${result.isSuccess}');
        debugPrint('User ID: ${result.userId}');
        debugPrint('User Name: ${result.userName}');
        debugPrint('Error Message: ${state.errorMessage}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.',
      );

      //LOG
      debugPrint('Login Error: $e');
    }
  }

  void logout() async {}
}

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LoginUseCase(apiService);
});

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>(
      (ref) => LoginViewModel(ref.watch(loginUseCaseProvider)),
    );
