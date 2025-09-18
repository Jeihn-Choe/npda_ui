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
