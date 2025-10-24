class LoginState {
  final bool isLoading;
  final String? errorMessage;

  final bool isValidForm;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isValidForm = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isValidForm,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isValidForm: isValidForm ?? this.isValidForm,
    );
  }
}
