import '../entities/robot_status_entity.dart';

abstract class RobotStatusRepository {
  Stream<RobotStatusEntity> get ssrStream;

  Stream<RobotStatusEntity> get spt1fStream;

  Stream<RobotStatusEntity> get spt3fStream;
}
