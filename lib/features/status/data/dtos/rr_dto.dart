class RequestRrDto {
  final String cmdId;
  final String robotId;
  final DateTime time;

  RequestRrDto({
    required this.cmdId,
    required this.robotId,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {'cmdId': cmdId, 'robotId': robotId, 'time': time.toIso8601String()};
  }
}

class ResponseRrDto {
  final String cmdId;
  final String result;
  final String msg;

  ResponseRrDto({required this.cmdId, required this.result, required this.msg});

  factory ResponseRrDto.fromJson(Map<String, dynamic> json) {
    return ResponseRrDto(
      cmdId: json["cmdId"] as String,
      result: json["result"] as String,
      msg: json["msg"] as String,
    );
  }
}
