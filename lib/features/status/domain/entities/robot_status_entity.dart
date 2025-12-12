import 'package:npda_ui_flutter/core/data/dtos/mqtt_messages/robot_status_dto.dart';

class RobotStatusEntity {
  final String robotId;
  final RobotRunState runState;
  final RobotDriveState driveState;
  final int errorCode;
  final String errorMsg;
  final DateTime timestamp; // String 그대로 유지 (필요시 DateTime 변환)

  RobotStatusEntity({
    required this.robotId,
    required this.runState,
    required this.driveState,
    required this.errorCode,
    required this.errorMsg,
    required this.timestamp,
  });

  RobotStatusEntity copyWith({
    String? robotId,
    RobotRunState? runState,
    RobotDriveState? driveState,
    int? errorCode,
    String? errorMsg,
    DateTime? timestamp,
  }) {
    return RobotStatusEntity(
      robotId: robotId ?? this.robotId,
      runState: runState ?? this.runState,
      driveState: driveState ?? this.driveState,
      errorCode: errorCode ?? this.errorCode,
      errorMsg: errorMsg ?? this.errorMsg,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
