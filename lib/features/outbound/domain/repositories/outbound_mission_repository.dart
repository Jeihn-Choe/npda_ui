import '../entities/outbound_mission_entity.dart';

abstract class OutboundMissionRepository {
  Stream<List<OutboundMissionEntity>> get outboundMissionStream;
}
