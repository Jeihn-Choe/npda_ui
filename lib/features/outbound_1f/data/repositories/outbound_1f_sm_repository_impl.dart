import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';

import '../../../../core/data/dtos/mqtt_messages/sm_dto.dart';
import '../../domain/entities/outbound_1f_sm_entity.dart';
import '../../domain/repositories/outbound_1f_sm_repository.dart';

class Outbound1fSmRepositoryImpl extends Outbound1fSmRepository {
  final MqttStreamRepository _mqttStreamRepository;

  Outbound1fSmRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<List<Outbound1fSmEntity>> get outbound1fSmStream =>
      _mqttStreamRepository.smStream.map((smDtoList) {
        return smDtoList
            .where((dto) => dto.missionType == 2) // missionType이 2인 항목 필터링 (출고)
            .map((dto) => _mapToEntity(dto))
            .toList();
      });

  Outbound1fSmEntity _mapToEntity(SmDto dto) {
    String convertedRobotName;
    switch (dto.robotName) {
      case "P2-AMR-8100":
        convertedRobotName = 'Forklift';
        break;
      case "P2-AMR-8101":
        convertedRobotName = 'PLT_1F';
        break;
      case "P2-AMR-8102":
        convertedRobotName = 'PLT_3F';
        break;
      default:
        convertedRobotName = 'Unknown';
    }

    return Outbound1fSmEntity(
      missionNo: dto.missionNo,
      subMissionNo: dto.subMissionNo,
      missionType: dto.missionType,
      pltNo: dto.huId,
      startTime: dto.startTime,
      sourceBin: dto.sourceBin,
      destinationBin: dto.destinationBin,
      isWrapped: dto.isWrapped,
      subMissionStatus: dto.subMissionStatus ?? 0,
      robotName: convertedRobotName,
    );
  }
}
