class LoginResult {
  final bool isSuccess;
  final String message;
  final String? userId;
  final String? userName;
  // 🚀 추가: userCode 필드
  final int? userCode;

  const LoginResult({
    required this.isSuccess,
    required this.message,
    this.userId,
    this.userName,
    // 🚀 추가: userCode 필드
    this.userCode,
  });

  // 🚀 수정: success 팩토리 생성자에 userCode 추가
  LoginResult.success({required String userId, required String userName, required int userCode})
    : this(
        isSuccess: true,
        message: 'Login successful',
        userId: userId,
        userName: userName,
        userCode: userCode, // 🚀 추가
      );

  // 🚀 수정: failure 팩토리 생성자에 userCode null로 설정
  LoginResult.failure(String errorMessage)
    : this(
        isSuccess: false,
        message: errorMessage,
        userId: null,
        userName: null,
        userCode: null, // 🚀 추가
      );
}
