// Login 관련 Viewmodel에서 관리하는 상태들 모음


class LoginState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;
  final String? userName;

  const LoginState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.errorMessage,
    this.userId,
    this.userName,
  });

  LoginState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? userId,
    String? userName,
  }) {
    return LoginState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }
}
