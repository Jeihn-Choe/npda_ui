import '../../../../core/data/dtos/mqtt_messages/po_dto.dart';
import '../../../../core/data/repositories/mqtt/mqtt_stream_repository.dart';
import '../../domain/entities/outbound_1f_po_entity.dart';
import '../../domain/repositories/outbound_1f_po_repository.dart';

class Outbound1fPoRepositoryImpl implements Outbound1fPoRepository {
  final MqttStreamRepository _mqttStreamRepository;

  Outbound1fPoRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<List<Outbound1fPoEntity>> get outbound1fPoStream =>
      _mqttStreamRepository.poStream.map((poDtoList) {
        return poDtoList
            .where((dto) => dto.missionType == 2)
            .map((dto) => _mapToEntity(dto))
            .toList();
      });

  Outbound1fPoEntity _mapToEntity(PoDto dto) {
    return Outbound1fPoEntity(
      missionType: dto.missionType,
      huId: dto.huId ?? '',
      targetRackLevel: dto.targetRackLevel,
      sourceBin: dto.sourceBin,
      destinationBin: dto.destinationBin,
      isWrapped: dto.isWrapped,
      destinationArea: dto.destinationArea,
      doNo: dto.doNo ?? '',
      uid: dto.uid,
    );
  }
}
