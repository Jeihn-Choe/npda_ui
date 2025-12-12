class RequestRpDto {
  final String cmdId;
  final String robotId;
  final DateTime time;

  RequestRpDto({
    required this.cmdId,
    required this.robotId,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {'cmdId': cmdId, 'robotId': robotId, 'time': time.toIso8601String()};
  }
}

class ResponseRpDto {
  final String cmdId;
  final String result;
  final String msg;

  ResponseRpDto({required this.cmdId, required this.result, required this.msg});

  factory ResponseRpDto.fromJson(Map<String, dynamic> json) {
    return ResponseRpDto(
      cmdId: json["cmdId"] as String,
      result: json["result"] as String,
      msg: json["msg"] as String,
    );
  }
}
