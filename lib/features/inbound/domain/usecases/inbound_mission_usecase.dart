import 'dart:async';

import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';
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

    _mqttMessageRouterUseCase.startListening();

    _smMissionSubscription = _mqttMessageRouterUseCase.smStream.listen((
      smEntities,
    ) {
      final inboundMissions = smEntities
          .where((sm) => sm.missionType == 0)
          .map((sm) => InboundMissionEntity.fromSmEntity(sm))
          .toList();
      _inboundMissionController.add(inboundMissions);
    });
  }

  Future<void> deleteMissions(List<String> missionNos) async {
    try {
      await _missionRepository.deleteMissions(missionNos);
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _smMissionSubscription?.cancel();
    _inboundMissionController.close();
  }
}
