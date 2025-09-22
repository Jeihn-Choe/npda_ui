import 'package:npda_ui_flutter/features/inbound/domain/entities/current_inbound_mission_entity.dart';
import 'package:npda_ui_flutter/features/inbound/domain/repositories/current_inbound_mission_repository.dart';

class GetCurrentInboundMissionsUseCase {
  final CurrentInboundMissionRepository _repository;

  GetCurrentInboundMissionsUseCase(this._repository);

  Stream<List<CurrentInboundMissionEntity>> call() {
    return _repository.currentInboundMissions;
  }
}
