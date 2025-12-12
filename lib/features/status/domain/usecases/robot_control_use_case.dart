import 'package:npda_ui_flutter/core/data/dtos/mqtt_messages/robot_status_dto.dart';
import 'package:npda_ui_flutter/features/status/domain/repositories/robot_control_repository.dart';

import '../entities/robot_status_entity.dart';

class RobotControlUseCase {
  final RobotControlRepository _repository;

  RobotControlUseCase(this._repository);

  Future<void> call(RobotStatusEntity robot) async {
    switch (robot.runState) {
      case RobotRunState.run:
        await _repository.pauseRobot(robot.robotId);
        break;
      case RobotRunState.pause:
        await _repository.resumeRobot(robot.robotId);
        break;
      default:
        break;
    }
  }
}
