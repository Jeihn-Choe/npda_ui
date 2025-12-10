import 'package:npda_ui_flutter/core/data/dtos/mqtt_messages/po_dto.dart';

import '../../../../core/data/repositories/mqtt/mqtt_stream_repository.dart';
import '../../domain/entities/inbound_po_entity.dart';
import '../../domain/repositories/inbound_po_repository.dart';

class InboundPoRepositoryImpl implements InboundPoRepository {
  final MqttStreamRepository _mqttStreamRepository;

  InboundPoRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<List<InboundPoEntity>> get inboundPoStream =>
      _mqttStreamRepository.poStream.map((poDtoList) {
        return poDtoList
            .where((dto) => dto.missionType == 0)
            .map((dto) => _mapToEntity(dto))
            .toList();
      });

  InboundPoEntity _mapToEntity(PoDto dto) {
    return InboundPoEntity(
      missionType: dto.missionType,
      huId: dto.huId ?? '',
      targetRackLevel: dto.targetRackLevel,
      sourceBin: dto.sourceBin,
      destinationBin: dto.destinationBin,
      isWrapped: dto.isWrapped,
      destinationArea: dto.destinationArea,
      doNo: dto.doNo ?? '',
    );
  }
}
