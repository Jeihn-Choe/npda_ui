import 'dart:async';

import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

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

    appLogger.d("[Outbound1F Mission UseCase] 아웃바운드1F 미션 수신 시작)");

    _smMissionSubscription = _mqttMessageRouterUseCase.smStream.listen((
      smEntities,
    ) {
      // [디버깅 로그 1] 원본 데이터 확인
      appLogger.d("[디버깅] 수신된 전체 SM Entities (${smEntities.length}개): }");

      // 1. missionType == 2 인 미션만 필터링
      final filteredEntities = smEntities
          .where((sm) => sm.missionType == 2)
          .toList();

      // [디버깅 로그 2] 필터링 후 데이터 확인
      appLogger.d(
        "[디버깅] 출고 미션(missionType:2)으로 필터링된 Entities (${filteredEntities.length}개): }",
      );

      // 2. OutboundMissionEntity로 변환 (매핑)
      final outbound1FMissions = filteredEntities
          .map((sm) => Outbound1FMissionEntity.fromSmEntity(sm))
          .toList();

      // [디버깅 로그 3] 최종 변환 데이터 확인
      appLogger.d(
        "[디버깅] 최종 변환된 OutboundMissions (${outbound1FMissions.length}개): }",
      );

      _outbound1FMissionController.add(outbound1FMissions);
    });
  }

  Future<bool> deleteSelectedOutbound1FMissions({
    required List<int> selectedMissionNos,
  }) async {
    appLogger.d("[Outbound Mission UseCase] 선택된 아웃바운드 미션 삭제 요청");

    try {
      final payload = selectedMissionNos.map((no) => no.toString()).toList();

      await _missionRepository.deleteMissions(payload);

      appLogger.d("[Outbound1F Mission UseCase] 아웃바운드 미션 삭제 성공");
      return Future.value(true);
    } catch (e) {
      appLogger.e("[Outbound1F Mission UseCase] 아웃바운드 미션 삭제 실패: $e");
      return Future.value(false);
    }
  }

  void dispose() {
    _smMissionSubscription?.cancel();
    _outbound1FMissionController.close();
  }
}