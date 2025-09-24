import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/delete_missions_entity.dart';

import '../../../../core/domain/repositories/mission_repository.dart';
import '../../../../core/providers/repository_providers.dart';

class DeleteMissionsUseCase {
  final MissionRepository _repository;

  DeleteMissionsUseCase(this._repository);

  Future<void> call(List<String> subMissionNos) async {
    final deleteMissionsEntity = DeleteMissionsEntity(
      subMissionNos: subMissionNos,
    );

    await _repository.deleteMissions(deleteMissionsEntity);
  }
}

final deleteMissionsUseCaseProvider = Provider<DeleteMissionsUseCase>((ref) {
  final repository = ref.read(missionRepositoryProvider);
  return DeleteMissionsUseCase(repository);
});
