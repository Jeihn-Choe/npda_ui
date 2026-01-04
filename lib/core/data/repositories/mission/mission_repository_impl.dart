import 'package:npda_ui_flutter/core/config/app_config.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/network/http/api_service.dart';

import '../../dtos/delete_missions_dto.dart';

class MissionRepositoryImpl implements MissionRepository {
  // ✨ 변경: extends -> implements
  final ApiService _apiService;

  MissionRepositoryImpl(this._apiService);

  @override
  // ✨ 변경: 파라미터를 List<String>으로 수정
  Future<void> deleteMissions(List<String> missionNos) async {
    try {
      // ✨ 변경: 파라미터로 받은 missionNos를 사용하여 DTO 생성
      final requestPayload = DeleteMissionsDto(payload: missionNos);

      await _apiService.post(
        ApiConfig.deleteOrderEndpoint,
        data: requestPayload.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
