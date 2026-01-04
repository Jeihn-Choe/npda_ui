import '../../../../core/data/repositories/mqtt/mqtt_stream_repository.dart';
import '../../domain/entities/ev_status_entity.dart';
import '../../domain/repositories/ev_status_repository.dart';

// ✨ Core의 MqttStreamRepository를 구독하여 EV 상태 정보를 제공하는 Repository 구현체
class EvStatusRepositoryImpl implements EvStatusRepository {
  final MqttStreamRepository _mqttStreamRepository;

  EvStatusRepositoryImpl(this._mqttStreamRepository);

  @override
  Stream<EvStatusEntity> getEvStatusStream() {
    // 🚀 Core의 List<EsDto> 스트림을 EvStatusEntity 스트림으로 변환
    return _mqttStreamRepository.esStream.map((esDtoList) {
      if (esDtoList.isEmpty) {
        return EvStatusEntity.initial();
      }

      // 🚀 리스트의 첫 번째 요소를 Entity로 변환하여 반환
      return esDtoList.first.toEntity();
    });
  }
}
