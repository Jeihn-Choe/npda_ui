import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/core/providers/usecase_providers.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_mission_entity.dart';

class InboundMissionUseCase {
  final Ref _ref;
  StreamSubscription? _smMissionSubscription;

  final _inboundMissionController =
      StreamController<List<InboundMissionEntity>>.broadcast();

  InboundMissionUseCase(this._ref);

  Stream<List<InboundMissionEntity>> get inboundMissionStream =>
      _inboundMissionController.stream;

  void startListening() {
    if (_smMissionSubscription != null) {
      return;
    }
    appLogger.d("[Inbound Mission UseCase] SM 스트림 구독 시작)");

    final mqttMessageRouterUseCase = _ref.read(
      mqttMessageRouterUseCaseProvider,
    );
    _smMissionSubscription = mqttMessageRouterUseCase.smStream.listen((
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
      final missionRepository = _ref.read(missionRepositoryProvider);
      await missionRepository.deleteMissions(missionNos);
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
