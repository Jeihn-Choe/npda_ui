class LoginResponseDTO {
  final String status;
  final String userId;
  final String userName;
  final String result;
  final String msg;

  LoginResponseDTO({
    required this.status,
    required this.userId,
    required this.userName,
    required this.result,
    required this.msg,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      status: json['status'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      result: json['result'] as String,
      msg: json['msg'] as String,
    );
  }
}
