import 'package:npda_ui_flutter/core/network/http/api_service.dart';
import 'package:npda_ui_flutter/features/status/data/dtos/rr_dto.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/repositories/robot_control_repository.dart';
import '../dtos/rp_dto.dart';

class RobotControlRepositoryImpl extends RobotControlRepository {
  final ApiService _apiService;

  RobotControlRepositoryImpl(this._apiService);

  @override
  Future<ResponseRpDto> pauseRobot(String robotId) async {
    RequestRpDto requestDto = RequestRpDto(
      cmdId: "RP",
      robotId: robotId,
      time: DateTime.now(),
    );

    final response = await _apiService.post(
      ApiConfig.pauseRobotEndpoint,
      data: requestDto.toJson(),
    );
    return ResponseRpDto.fromJson(response);
  }

  @override
  Future<ResponseRrDto> resumeRobot(String robotId) async {
    RequestRrDto requestRrDto = RequestRrDto(
      cmdId: "RR",
      robotId: robotId,
      time: DateTime.now(),
    );

    final response = await _apiService.post(
      ApiConfig.resumeRobotEndpoint,
      data: requestRrDto.toJson(),
    );
    return ResponseRrDto.fromJson(response);
  }
}
