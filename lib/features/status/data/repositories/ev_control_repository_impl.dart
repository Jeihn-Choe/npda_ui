import '../../../../core/config/app_config.dart';
import '../../../../core/network/http/api_service.dart';
import '../../domain/repositories/ev_control_repository.dart';
import '../dtos/ee_dto.dart';

// ✨ EV 상태 제어 요청을 처리하는 Repository 구현체
class EvControlRepositoryImpl implements EvControlRepository {
  final ApiService _apiService;

  EvControlRepositoryImpl(this._apiService);

  @override
  Future<void> updateEvStatus({
    required bool isMainError,
    required bool isSubError,
  }) async {
    final requestDto = RequestEeDto(
      cmdId: "EE",
      payload: EePayloadDto(
        isMainError: isMainError,
        isSubError: isSubError,
      ),
    );

    // 🚀 ApiConfig에 정의된 엔드포인트(/status/elevator/error)로 POST 요청
    await _apiService.post(
      ApiConfig.reportEvStatusEndpoint,
      data: requestDto.toJson(),
    );
  }
}
