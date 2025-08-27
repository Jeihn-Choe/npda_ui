import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/network/http/api_provider.dart';
import 'package:npda_ui_flutter/core/network/http/api_service.dart';

import '../../../core/config/api_config.dart';

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
    this.userId,
    this.userName,
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

  static const initial = LoginState();
}

class LoginViewModel extends StateNotifier<LoginState> {
  /// 주입하고 싶은 서비스들을 먼저 선언 => 이후 provider에서 생성할 때 주입할거임
  final ApiService _apiService;

  /// controller 선언해줌.
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginViewModel(this._apiService) : super(LoginState.initial);

  /// getter 써서 접근 가능하게 해줌 => 외부에서 controller 직접 접근 가능하도록 함.

  TextEditingController get userIdController => _userIdController;

  TextEditingController get passwordController => _passwordController;

  void disposeControllers() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void validateForm(String userId, String password) {
    final isValid = userId.trim().isNotEmpty && password.trim().isNotEmpty;

    if (!isValid) {
      state = state.copyWith(errorMessage: '아이디와 비밀번호를 모두 입력해주세요.');
    }

    state = state.copyWith(isValidForm: isValid, errorMessage: null);
  }

  Future<void> login(String userId, String password) async {
    state = state.copyWith(errorMessage: null);

    validateForm(userId, password);

    if (!state.isValidForm) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {'userId': userId.trim(), 'password': password.trim()},
      );

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: userId,
        userName: response['userName'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.',
      );
    }
  }

  void logout() async {}
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>(
      (ref) => LoginViewModel(ref.watch(apiServiceProvider)),
    );
