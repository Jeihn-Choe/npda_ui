import 'package:npda_ui_flutter/core/utils/logger.dart';

class LoginResponseDTO {
  final String status;
  final String userId;
  final String userName;
  // 🚀 추가: userCode 필드
  final int userCode;
  final String result;
  final String msg;

  LoginResponseDTO({
    required this.status,
    required this.userId,
    required this.userName,
    // 🚀 추가: userCode 필드
    required this.userCode,
    required this.result,
    required this.msg,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    logger("============== login Json 변환중==============");

    return LoginResponseDTO(
      status: json['status'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      // 🚀 추가: userCode 파싱
      userCode: json['userCode'] as int,
      result: json['result'] as String,
      msg: json['msg'] as String,
    );
  }
}
