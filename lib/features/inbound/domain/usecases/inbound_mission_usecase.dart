import 'dart:async';

import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';

import '../../../../core/utils/logger.dart';
import '../entities/inbound_mission_entity.dart';

class InboundMissionUseCase {
  final MqttMessageRouterUseCase _mqttMessageRouterUseCase;
  StreamSubscription? _smMissionSubscription;

  final _inboundMissionStreamController =
      StreamController<List<InboundMissionEntity>>.broadcast();

  Stream<List<InboundMissionEntity>> get inboundMissionStream =>
      _inboundMissionStreamController.stream;

  InboundMissionUseCase(this._mqttMessageRouterUseCase);

  void startListening() {
    if (_smMissionSubscription != null) {
      return;
    }

    appLogger.d("[Inbound Mission UseCase] SM 스트림 구독 시작)");

    _smMissionSubscription = _mqttMessageRouterUseCase.smStream.listen((
      smEntities,
    ) {
      appLogger.d(
        "[Inbound Mission UseCase] SM 메시지 수신: ${smEntities.length} 개 미션",
      );

      final inboundMissions = smEntities
          .where((sm) => sm.missionType == 0)
          .map((sm) => InboundMissionEntity.fromSmEntity(sm))
          .toList();

      _inboundMissionStreamController.add(inboundMissions);
    });
  }

  void dispose() {
    _smMissionSubscription?.cancel();
    _inboundMissionStreamController.close();
  }
}
