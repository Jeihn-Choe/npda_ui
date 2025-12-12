import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';

import '../../domain/entities/robot_status_entity.dart';
import '../../domain/repositories/robot_status_repository.dart';

class RobotStatusRepositoryImpl extends RobotStatusRepository {
  final MqttStreamRepository _mqttStreamRepository;

  RobotStatusRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<RobotStatusEntity> get ssrStream =>
      _mqttStreamRepository.ssrStream.map((dto) {
        return RobotStatusEntity(
          robotId: dto.robotId,
          runState: dto.runState,
          driveState: dto.driveState,
          errorCode: dto.errorCode ?? 0,
          errorMsg: dto.errorMsg ?? '',
          timestamp: dto.timestamp,
        );
      });

  @override
  Stream<RobotStatusEntity> get spt1fStream =>
      _mqttStreamRepository.spt1fStream.map((dto) {
        return RobotStatusEntity(
          robotId: dto.robotId,
          runState: dto.runState,
          driveState: dto.driveState,
          errorCode: dto.errorCode ?? 0,
          errorMsg: dto.errorMsg ?? '',
          timestamp: dto.timestamp,
        );
      });

  @override
  Stream<RobotStatusEntity> get spt3fStream =>
      _mqttStreamRepository.spt3fStream.map((dto) {
        return RobotStatusEntity(
          robotId: dto.robotId,
          runState: dto.runState,
          driveState: dto.driveState,
          errorCode: dto.errorCode ?? 0,
          errorMsg: dto.errorMsg ?? '',
          timestamp: dto.timestamp,
        );
      });
}
