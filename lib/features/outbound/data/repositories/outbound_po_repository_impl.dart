// lib/features/outbound/data/repositories/outbound_po_repository_impl.dart

import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';
import 'package:npda_ui_flutter/features/outbound/domain/repositories/outbound_po_repository.dart';

import '../../../../core/data/dtos/mqtt_messages/po_dto.dart';
import '../../domain/entities/outbound_po_entity.dart';

class OutboundPoRepositoryImpl implements OutboundPoRepository {
  final MqttStreamRepository _mqttStreamRepository;

  OutboundPoRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<List<OutboundPoEntity>> get outboundPoStream =>
      _mqttStreamRepository.poStream.map((poDtoList) {
        return poDtoList
            .where((dto) => dto.missionType == 1)
            .map((dto) => _mapToEntity(dto))
            .toList();
      });

  OutboundPoEntity _mapToEntity(PoDto dto) {
    return OutboundPoEntity(
      missionType: dto.missionType,
      huId: dto.huId ?? '',
      targetRackLevel: dto.targetRackLevel,
      sourceBin: dto.sourceBin,
      destinationBin: dto.destinationBin,
      isWrapped: dto.isWrapped,
      destinationArea: dto.destinationArea,
      doNo: dto.doNo ?? '',
      uid: dto.uid,
      subMissionNo: null,
      subMissionStatus: null,
    );
  }
}
