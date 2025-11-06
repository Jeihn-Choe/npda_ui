import 'dart:async';

import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_mission_entity.dart';

class InboundMissionUseCase {
  final MqttMessageRouterUseCase _mqttMessageRouterUseCase;
  final MissionRepository _missionRepository;
  StreamSubscription? _smMissionSubscription;

  final _inboundMissionController =
      StreamController<List<InboundMissionEntity>>.broadcast();

  InboundMissionUseCase(
    this._mqttMessageRouterUseCase,
    this._missionRepository,
  );

  Stream<List<InboundMissionEntity>> get inboundMissionStream =>
      _inboundMissionController.stream;

  void startListening() {
    if (_smMissionSubscription != null) {
      return;
    }
    appLogger.d("[Inbound Mission UseCase] SM 스트림 구독 시작)");

    _mqttMessageRouterUseCase.startListening();

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
      _inboundMissionController.add(inboundMissions);
    });
  }

  Future<void> deleteMissions(List<String> missionNos) async {
    appLogger.d("[Inbound Mission UseCase] 선택된 인바운드 미션 삭제 요청");
    try {
      await _missionRepository.deleteMissions(missionNos);
      appLogger.d("[Inbound Mission UseCase] 인바운드 미션 삭제 성공");
    } catch (e) {
      appLogger.e("[Inbound Mission UseCase] 인바운드 미션 삭제 실패: $e");
      rethrow;
    }
  }

  void dispose() {
    _smMissionSubscription?.cancel();
    _inboundMissionController.close();
  }
}
