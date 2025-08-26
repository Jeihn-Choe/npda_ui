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
  final ApiService _apiService;

  LoginViewModel(this._apiService) : super(LoginState.initial);

  void validateForm(String id, String password) {
    final isValid = id
        .trim()
        .isNotEmpty && password
        .trim()
        .isNotEmpty;
    state = state.copyWith(
      isValidForm: isValid,
      errorMessage: null,
    );
  }

  Future<void> login(String id, String password) async {
    if (!state.isValidForm) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiService.post(
          ApiConfig.loginEndpoint,
          data: {
            'userId': id.trim(),
            'password': password.trim(),
          }
      );

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        userId: id.trim(),
        userName: response['userName'],

      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.',
      );
    }
  }

  void logout() async {
  }
}
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>(
      (ref)=>LoginViewModel(ref.watch(apiServiceProvider)),
);
