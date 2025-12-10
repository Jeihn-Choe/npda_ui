import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';
import 'package:npda_ui_flutter/features/outbound_1f/domain/repositories/outbound_1f_mission_repository.dart';

import '../../../../core/data/dtos/mqtt_messages/sm_dto.dart';
import '../../domain/entities/outbound_1f_mission_entity.dart';

class Outbound1FMissionRepositoryImpl implements Outbound1FMissionRepository {
  final MqttStreamRepository _mqttStreamRepository;

  Outbound1FMissionRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<List<Outbound1FMissionEntity>> get outbound1fMissionStream =>
      _mqttStreamRepository.smStream.map((smDtoList) {
        return smDtoList
            .where(
              (dto) => dto.missionType == 2,
            ) // ✨ outbound 1F (missionType == 2) 필터링
            .map((dto) => _mapToEntity(dto))
            .toList();
      });

  Outbound1FMissionEntity _mapToEntity(SmDto dto) {
    return Outbound1FMissionEntity(
      missionNo: dto.missionNo ?? 0,
      subMissionNo: dto.subMissionNo ?? 0,
      pltNo: dto.huId ?? '',
      sourceBin: dto.sourceBin ?? '',
      destinationBin: dto.destinationBin ?? '',
      subMissionStatus: dto.subMissionStatus,
      // Outbound1FMissionEntity는 nullable
      startTime: dto.startTime,
      // Outbound1FMissionEntity는 nullable
      missionType: dto.missionType ?? 0,
      isWrapped: dto.isWrapped ?? false,
      robotName: dto.robotName, // Outbound1FMissionEntity는 nullable
    );
  }
}
