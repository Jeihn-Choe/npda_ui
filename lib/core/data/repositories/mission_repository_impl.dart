import 'package:npda_ui_flutter/core/config/app_config.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/network/http/api_service.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/delete_missions_entity.dart';

import '../dtos/delete_missions_dto.dart';

class MissionRepositoryImpl extends MissionRepository {
  final ApiService _apiService;

  MissionRepositoryImpl(this._apiService);

  @override
  Future<void> deleteMissions(DeleteMissionsEntity entity) async {
    try {
      /// repository의 책임 : entity --> dto 변환
      final requestPayload = DeleteMissionsDto(payload: entity.subMissionNos);

      appLogger.d("[MissionRepositoryImpl] 미션 삭제 요청: $requestPayload");

      await _apiService.post(
        ApiConfig.deleteOrderEndpoint,
        data: requestPayload.toJson(),
      );
    } catch (e) {
      appLogger.e("[MissionRepositoryImpl] 미션 삭제 실패: $e");
      rethrow;
    }
  }
}
