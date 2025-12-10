// lib/features/outbound/data/repositories/outbound_sm_repository_impl.dart

import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';
import 'package:npda_ui_flutter/features/outbound/domain/repositories/outbound_sm_repository.dart';

import '../../../../core/data/dtos/mqtt_messages/sm_dto.dart';
import '../../domain/entities/outbound_sm_entity.dart';

class OutboundSmRepositoryImpl implements OutboundSmRepository {
  final MqttStreamRepository _mqttStreamRepository;

  OutboundSmRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<List<OutboundSmEntity>> get outboundSmStream =>
      _mqttStreamRepository.smStream.map((smDtoList) {
        return smDtoList
            .where((dto) => dto.missionType == 1) // missionType이 1인 항목 필터링 (출고)
            .map((dto) => _mapToEntity(dto))
            .toList();
      });

  OutboundSmEntity _mapToEntity(SmDto dto) {
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

    return OutboundSmEntity(
      missionNo: dto.missionNo ?? 0,
      subMissionNo: dto.subMissionNo ?? 0,
      missionType: dto.missionType ?? 0,
      pltNo: dto.huId ?? '',
      doNo: dto.doNo ?? '',
      startTime: dto.startTime ?? '',
      sourceBin: dto.sourceBin ?? '',
      destinationBin: dto.destinationBin ?? '',
      isWrapped: dto.isWrapped ?? false,
      subMissionStatus: dto.subMissionStatus ?? 0,
      robotName: convertedRobotName ?? '',
    );
  }
}
