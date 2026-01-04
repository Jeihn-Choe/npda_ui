// ✨ EV 상태 변경 요청 DTO (EE)
class RequestEeDto {
  final String cmdId;
  final EePayloadDto payload;

  RequestEeDto({
    required this.cmdId,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'cmdId': cmdId,
      'payload': payload.toJson(),
    };
  }
}

class EePayloadDto {
  final bool isMainError;
  final bool isSubError;

  EePayloadDto({
    required this.isMainError,
    required this.isSubError,
  });

  Map<String, dynamic> toJson() {
    return {
      'main': isMainError,
      'sub': isSubError,
    };
  }
}

// ✨ EV 상태 변경 응답 DTO
class ResponseEeDto {
  final String cmdId;
  final String result; // 'S' or 'F'
  final String msg;

  ResponseEeDto({
    required this.cmdId,
    required this.result,
    required this.msg,
  });

  factory ResponseEeDto.fromJson(Map<String, dynamic> json) {
    return ResponseEeDto(
      cmdId: json['cmdId'] as String,
      result: json['result'] as String,
      msg: json['msg'] as String? ?? '',
    );
  }
}
