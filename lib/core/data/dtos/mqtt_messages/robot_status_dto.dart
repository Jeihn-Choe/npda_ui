/// 로봇 상태 정보 DTO
class RobotStatusDto {
  /// 로봇 이름
  final String robotId;

  /// 로봇 상태 (0: Idle, 1: Run, 2: Pause, 3: Error)
  final RobotRunState runState;

  /// 로봇 모터 상태 (0: Stop, 1: Run)
  final RobotDriveState driveState;

  /// 에러 코드 (에러 발생 시)
  final int? errorCode;

  /// 에러 메시지
  final String? errorMsg;

  /// 타임스탬프 (yyyy-MM-dd HH:mm:ss.fff)
  final DateTime timestamp;

  RobotStatusDto({
    required this.robotId,
    required this.runState,
    required this.driveState,
    this.errorCode,
    this.errorMsg,
    required this.timestamp,
  });

  /// JSON to DTO
  factory RobotStatusDto.fromJson(Map<String, dynamic> json) {
    return RobotStatusDto(
      robotId: json['robotId'] as String,
      runState: RobotRunState.fromValue(json['runState'] as num),
      driveState: RobotDriveState.fromValue(json['driveState'] as num),
      errorCode: json['errorCode'] as int?,
      errorMsg: json['errorMsg'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'robotId': robotId,
      'runState': runState.value,
      'driveState': driveState.value,
      'errorCode': errorCode,
      'errorMsg': errorMsg,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// copyWith
  RobotStatusDto copyWith({
    String? robotId,
    RobotRunState? runState,
    RobotDriveState? driveState,
    int? errorCode,
    String? errorMsg,
    DateTime? timestamp,
  }) {
    return RobotStatusDto(
      robotId: robotId ?? this.robotId,
      runState: runState ?? this.runState,
      driveState: driveState ?? this.driveState,
      errorCode: errorCode ?? this.errorCode,
      errorMsg: errorMsg ?? this.errorMsg,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// 로봇 실행 상태
enum RobotRunState {
  /// 대기
  idle(0, '대기'),

  /// 실행 중
  run(1, '실행 중'),

  /// 일시정지
  pause(2, '일시정지'),

  /// 에러
  error(3, '에러');

  final num value;
  final String description;

  const RobotRunState(this.value, this.description);

  static RobotRunState fromValue(num value) {
    return RobotRunState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => RobotRunState.idle,
    );
  }
}

/// 로봇 모터 상태
enum RobotDriveState {
  /// 정지
  stop(0, '정지'),

  /// 실행 중
  run(1, '실행 중');

  final num value;
  final String description;

  const RobotDriveState(this.value, this.description);

  static RobotDriveState fromValue(num value) {
    return RobotDriveState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => RobotDriveState.stop,
    );
  }
}
