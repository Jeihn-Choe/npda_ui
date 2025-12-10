import '../entities/outbound_1f_mission_entity.dart';

abstract class Outbound1FMissionRepository {
  Stream<List<Outbound1FMissionEntity>> get outbound1fMissionStream;
}
