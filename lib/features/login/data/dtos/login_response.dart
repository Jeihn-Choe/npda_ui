class LoginResponseDTO {
  final String cmdId;
  final String userId;
  final String name;
  final int code;
  final String result;
  final String msg;

  LoginResponseDTO({
    required this.cmdId,
    required this.userId,
    required this.name,
    required this.code,
    required this.result,
    required this.msg,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      // null-safe 파싱: 대소문자 두 가지 모두 시도
      cmdId: json['cmdId']?.toString() ?? json['CmdId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['UserId']?.toString() ?? '',
      name: json['name']?.toString() ?? json['Name']?.toString() ?? '',
      
      // code: int 파싱 (기본값: 1 = guest)
      code: _parseCode(json['code'] ?? json['Code']),
      
      // result: String 파싱 (기본값: 'F' = 실패)
      result: json['result']?.toString() ?? json['Result']?.toString() ?? 'F',
      
      // msg: String 파싱 (기본값: 빈 문자열)
      msg: json['msg']?.toString() ?? json['Msg']?.toString() ?? '',
    );
  }
  
  /// code 필드를 안전하게 int로 변환
  static int _parseCode(dynamic value) {
    if (value == null) return 1; // 기본값: guest
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
  
  /// 성공 여부 판단 (result가 'S' 또는 '0'이면 성공)
  bool get isSuccess => result == 'S' || result == '0';
  
  /// 관리자 여부 (code가 0이면 관리자)
  bool get isAdmin => code == 0;
  
  @override
  String toString() {
    return 'LoginResponseDTO('
        'cmdId: $cmdId, '
        'userId: $userId, '
        'name: $name, '
        'code: $code, '
        'result: $result, '
        'msg: $msg, '
        'isSuccess: $isSuccess, '
        'isAdmin: $isAdmin'
        ')';
  }
}
