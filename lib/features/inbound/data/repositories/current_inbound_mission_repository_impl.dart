import 'dart:async';

import 'package:npda_ui_flutter/core/data/dtos/mqtt_receive_raw_dto.dart';
import 'package:npda_ui_flutter/features/inbound/domain/repositories/current_inbound_mission_repository.dart';

import '../../domain/entities/current_inbound_mission_entity.dart';

class CurrentInboundMissionRepositoryImpl
    implements CurrentInboundMissionRepository {
  final _inboundMissionListController =
      StreamController<List<CurrentInboundMissionEntity>>.broadcast();

  @override
  Stream<List<CurrentInboundMissionEntity>> get currentInboundMissions =>
      _inboundMissionListController.stream;

  @override
  void updateInboundMissionList(List<dynamic> payload) {
    // payload를 CurrentInboundMissionEntity 리스트로 변환
    final subMissions = payload
        .map((item) => SubMissionDto.fromJson(item))
        .toList();

    /// 입고미션에 해당하는 미션만 필터링 (missionType == 0)///
    final inboundSubMissions = subMissions.where((mission) {
      return mission.missionType == 0;
    }).toList();

    /// 3. List<SubMissionDto> -> List<CurrentInboundMissionEntity> 변환 ///
    final inboundSubMissionEntities = inboundSubMissions.map((dto) {
      return CurrentInboundMissionEntity(
        missionNo: dto.missionNo,
        subMissionNo: dto.subMissionNo,
        missionType: dto.missionType,
        pltNo: dto.pltNo,
        startTime: dto.startTime,
        targetRackLevel: dto.targetRackLevel,
        sourceBin: dto.sourceBin,
        destinationBin: dto.destinationBin,
        isWrapped: dto.isWrapped,
        subMissionStatus: dto.subMissionStatus,
      );
    }).toList();

    /// 4. StreamController를 통해 새로운 리스트를 스트림에 추가 ///
    _inboundMissionListController.add(inboundSubMissionEntities);
  }

  void dispose() {
    _inboundMissionListController.close();
  }
}
