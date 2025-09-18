class ResponseOrderDto {
  final String? cmdId;
  final String? result;
  final String? msg;

  ResponseOrderDto({this.cmdId, this.result, this.msg});

  factory ResponseOrderDto.fromJson(Map<String, dynamic> json) {
    return ResponseOrderDto(
      cmdId: json['cmdId'] as String?,
      result: json['result'] as String?,
      msg: json['msg'] as String?,
    );
  }
}
