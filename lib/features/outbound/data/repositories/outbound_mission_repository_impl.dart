import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';
import 'package:npda_ui_flutter/features/outbound/domain/repositories/outbound_mission_repository.dart';

import '../../../../core/data/dtos/mqtt_messages/sm_dto.dart';
import '../../domain/entities/outbound_mission_entity.dart';

class OutboundMissionRepositoryImpl implements OutboundMissionRepository {
  final MqttStreamRepository _mqttStreamRepository;

  OutboundMissionRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<List<OutboundMissionEntity>> get outboundMissionStream =>
      _mqttStreamRepository.smStream.map((smDtoList) {
        return smDtoList
            .where((dto) => dto.missionType == 1) // ✨ outbound (missionType == 1) 필터링
            .map((dto) => _mapToEntity(dto))
            .toList();
      });

  OutboundMissionEntity _mapToEntity(SmDto dto) {
    return OutboundMissionEntity(
      missionNo: dto.missionNo ?? 0,
      subMissionNo: dto.subMissionNo ?? 0,
      pltNo: dto.huId ?? '', // SmDto.huId -> OutboundMissionEntity.pltNo
      doNo: dto.doNo ?? '',
      sourceBin: dto.sourceBin ?? '',
      destinationBin: dto.destinationBin ?? '',
      subMissionStatus: dto.subMissionStatus, // OutboundMissionEntity는 nullable
      startTime: dto.startTime, // OutboundMissionEntity는 nullable
      missionType: dto.missionType ?? 0,
      isWrapped: dto.isWrapped ?? false,
      robotName: dto.robotName, // OutboundMissionEntity는 nullable
    );
  }
}
