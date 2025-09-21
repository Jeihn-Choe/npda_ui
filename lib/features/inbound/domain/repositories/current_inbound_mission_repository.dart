import '../entities/current_inbound_mission_entity.dart';

abstract class CurrentInboundMissionRepository {
  /// 현재 입고 미션 리스트를 실시간으로 제공하는 스트림
  Stream<List<CurrentInboundMissionEntity>> get currentInboundMissions;

  /// 현재 입고 미션 정보를 업데이트하는 기능
  /// 외부(Data 계층의 router) 에서 호출하여 실시간 업데이터 반영
  void updateInboundMissionList(List<dynamic> payload);
}
