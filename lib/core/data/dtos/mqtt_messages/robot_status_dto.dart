/// 로봇 상태 정보 DTO
class RobotStatusDto {
  final String robotId;
  final RobotRunState runState;
  final RobotDriveState driveState;
  final int? errorCode;
  final String? errorMsg;
  final DateTime timestamp;

  RobotStatusDto({
    required this.robotId,
    required this.runState,
    required this.driveState,
    this.errorCode,
    this.errorMsg,
    required this.timestamp,
  });

  factory RobotStatusDto.fromJson(Map<String, dynamic> json) {
    return RobotStatusDto(
      robotId: json['robotId'] as String,
      // JSON에서 1.0(float)이 와도 num으로 받고, Enum 내부에서 toInt() 처리
      runState: RobotRunState.fromValue(json['runState'] as num),
      driveState: RobotDriveState.fromValue(json['driveState'] as num),
      errorCode: json['errorCode'] as int?,
      errorMsg: json['errorMsg'] as String?,
      // DateTime.parse는 'yyyy-MM-dd HH:mm:ss' 포맷(공백 포함)도 대부분 처리하지만,
      // 혹시 모를 파싱 에러 방지를 위해 tryParse 혹은 공백 치환을 고려할 수 있습니다.
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'robotId': robotId,
      'runState': runState.value, // int 값 나감 (예: 1)
      'driveState': driveState.value,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // copyWith 생략 (기존과 동일)
}

/// 로봇 실행 상태
enum RobotRunState {
  idle(0, '대기'),
  run(1, '실행 중'),
  pause(2, '일시정지'),
  error(3, '에러'),
  unknown(-1, '알 수 없음'); // 예외 처리를 위한 unknown 추가 추천

  final int value; // num -> int로 변경 (상태값은 정수 성격이 강함)
  final String description;

  const RobotRunState(this.value, this.description);

  static RobotRunState fromValue(num value) {
    // 들어오는 값이 1.0 이어도 1로 변환하여 비교 (가장 안전함)
    final int intValue = value.toInt();

    return RobotRunState.values.firstWhere(
      (state) => state.value == intValue,
      orElse: () => RobotRunState.unknown, // 없는 값이 오면 unknown 처리
    );
  }
}

/// 로봇 모터 상태
enum RobotDriveState {
  stop(0, '정지'),
  run(1, '실행 중'),
  unknown(-1, '알 수 없음');

  final int value; // num -> int로 변경
  final String description;

  const RobotDriveState(this.value, this.description);

  static RobotDriveState fromValue(num value) {
    final int intValue = value.toInt();

    return RobotDriveState.values.firstWhere(
      (state) => state.value == intValue,
      orElse: () => RobotDriveState.unknown,
    );
  }
}
