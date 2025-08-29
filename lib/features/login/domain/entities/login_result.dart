class LoginResult {
  final bool isSuccess;
  final String message;
  final String? userId;
  final String? userName;

  const LoginResult({
    required this.isSuccess,
    required this.message,
    this.userId,
    this.userName,
  });

  LoginResult.success({required String userId, required String userName})
    : this(
        isSuccess: true,
        message: 'Login successful',
        userId: userId,
        userName: userName,
      );

  LoginResult.failure(String errorMessage)
    : this(
        isSuccess: false,
        message: errorMessage,
        userId: null,
        userName: null,
      );
}
