import 'dart:async';

import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_mission_entity.dart';

class OutboundMissionUseCase {
  final MqttMessageRouterUseCase _mqttMessageRouterUseCase;
  StreamSubscription? _smMissionSubscription;

  /// OuntboundMission 담을 StreamController
  final _outboundMissionController =
      StreamController<List<OutboundMissionEntity>>.broadcast();

  OutboundMissionUseCase(this._mqttMessageRouterUseCase);

  /// OutboundMission 스트림 외부 노출 위한 getter 정의
  Stream<List<OutboundMissionEntity>> get outboundMissionStream =>
      _outboundMissionController.stream;

  void startListening() {
    if (_smMissionSubscription != null) {
      // 이미 구독 중인 경우 중복 구독 방지
      return;
    }

    appLogger.d("[Outbound Mission UseCase] 아웃바운드 미션 수신 시작)");

    _smMissionSubscription = _mqttMessageRouterUseCase.smStream.listen((
      smEntities,
    ) {
      appLogger.d(
        "[Outbound Mission UseCase] SM 메시지 수신: ${smEntities.length} 개 미션",
      );

      final outboundMissions = smEntities
          .where((sm) => sm.missionType == 1)
          .map((sm) => OutboundMissionEntity.fromSmEntity(sm))
          .toList();

      _outboundMissionController.add(outboundMissions);
    });
  }
}
