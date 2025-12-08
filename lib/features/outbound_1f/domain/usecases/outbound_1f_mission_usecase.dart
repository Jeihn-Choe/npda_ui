import 'dart:async';

import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';

import '../entities/outbound_1f_mission_entity.dart';

class Outbound1FMissionUseCase {
  final MqttMessageRouterUseCase _mqttMessageRouterUseCase;
  final MissionRepository _missionRepository;
  StreamSubscription? _smMissionSubscription;

  /// OuntboundMission 담을 StreamController
  final _outbound1FMissionController =
      StreamController<List<Outbound1FMissionEntity>>.broadcast();

  Outbound1FMissionUseCase(
    this._mqttMessageRouterUseCase,
    this._missionRepository,
  );

  /// OutboundMission 스트림 외부 노출 위한 getter 정의
  Stream<List<Outbound1FMissionEntity>> get outbound1FMissionStream =>
      _outbound1FMissionController.stream;

  void startListening() {
    if (_smMissionSubscription != null) {
      // 이미 구독 중인 경우 중복 구독 방지
      return;
    }

    _smMissionSubscription = _mqttMessageRouterUseCase.smStream.listen((
      smEntities,
    ) {
      // 1. missionType == 2 인 미션만 필터링
      final filteredEntities = smEntities
          .where((sm) => sm.missionType == 2)
          .toList();

      // 2. OutboundMissionEntity로 변환 (매핑)
      final outbound1FMissions = filteredEntities
          .map((sm) => Outbound1FMissionEntity.fromSmEntity(sm))
          .toList();

      _outbound1FMissionController.add(outbound1FMissions);
    });
  }

  Future<bool> deleteSelectedOutbound1FMissions({
    required List<int> selectedMissionNos,
  }) async {
    try {
      final payload = selectedMissionNos.map((no) => no.toString()).toList();

      await _missionRepository.deleteMissions(payload);

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  void dispose() {
    _smMissionSubscription?.cancel();
    _outbound1FMissionController.close();
  }
}
