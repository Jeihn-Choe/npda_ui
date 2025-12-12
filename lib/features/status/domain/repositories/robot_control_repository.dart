import 'package:npda_ui_flutter/features/status/data/dtos/rr_dto.dart';

import '../../data/dtos/rp_dto.dart';

abstract class RobotControlRepository {
  Future<ResponseRpDto> pauseRobot(String robotId);

  Future<ResponseRrDto> resumeRobot(String robotId);
}
