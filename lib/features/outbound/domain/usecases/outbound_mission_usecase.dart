import 'dart:async';

import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';

import '../entities/outbound_mission_entity.dart';

class OutboundMissionUseCase {
  final MqttMessageRouterUseCase _mqttMessageRouterUseCase;
  final MissionRepository _missionRepository;
  StreamSubscription? _smMissionSubscription;

  /// OuntboundMission 담을 StreamController
  final _outboundMissionController =
      StreamController<List<OutboundMissionEntity>>.broadcast();

  OutboundMissionUseCase(
    this._mqttMessageRouterUseCase,
    this._missionRepository,
  );

  /// OutboundMission 스트림 외부 노출 위한 getter 정의
  Stream<List<OutboundMissionEntity>> get outboundMissionStream =>
      _outboundMissionController.stream;

  void startListening() {
    if (_smMissionSubscription != null) {
      // 이미 구독 중인 경우 중복 구독 방지
      return;
    }

    _smMissionSubscription = _mqttMessageRouterUseCase.smStream.listen((
      smEntities,
    ) {
      // 1. missionType == 1 인 미션만 필터링
      final filteredEntities = smEntities
          .where((sm) => sm.missionType == 1)
          .toList();

      // 2. OutboundMissionEntity로 변환 (매핑)
      final outboundMissions = filteredEntities
          .map((sm) => OutboundMissionEntity.fromSmEntity(sm))
          .toList();

      _outboundMissionController.add(outboundMissions);
    });
  }

  Future<bool> deleteSelectedOutboundMissions({
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
    _outboundMissionController.close();
  }
}