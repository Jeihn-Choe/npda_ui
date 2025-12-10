import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';

import '../../../../core/data/dtos/mqtt_messages/sm_dto.dart';
import '../../domain/entities/inbound_sm_entity.dart';
import '../../domain/repositories/inbound_sm_repository.dart';

class InboundSmRepositoryImpl implements InboundSmRepository {
  final MqttStreamRepository _mqttStreamRepository;

  InboundSmRepositoryImpl(this._mqttStreamRepository);

  // smDto를 InboundMissionEntity로 매핑 후 inboundMissionStream으로 제공
  @override
  Stream<List<InboundSmEntity>> get inboundMissionStream =>
      _mqttStreamRepository.smStream.map((smDtoList) {
        return smDtoList
            .where((dto) => dto.missionType == 0) // missionType이 0인 항목 필터링
            .map((dto) => _mapToEntity(dto)) //entity로 변환
            .toList();
      });

  /// DTO -> Entity 변환 메서드 (Mapper 역할)
  InboundSmEntity _mapToEntity(SmDto dto) {
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

    return InboundSmEntity(
      missionNo: dto.missionNo,
      subMissionNo: dto.subMissionNo,
      missionType: dto.missionType,
      pltNo: dto.huId,
      startTime: dto.startTime,
      targetRackLevel: dto.targetRackLevel ?? 0,
      sourceBin: dto.sourceBin,
      destinationBin: dto.destinationBin,
      isWrapped: dto.isWrapped,
      subMissionStatus: dto.subMissionStatus ?? 0,
      robotName: convertedRobotName,
    );
  }
}
