import '../repositories/ev_control_repository.dart';

// ✨ EV 상태 제어 비즈니스 로직을 담당하는 UseCase
class EvControlUseCase {
  final EvControlRepository _repository;

  EvControlUseCase(this._repository);

  // 🚀 메인/서브 EV 상태 업데이트 명령 실행
  Future<void> execute({
    required bool isMainError,
    required bool isSubError,
  }) async {
    return await _repository.updateEvStatus(
      isMainError: isMainError,
      isSubError: isSubError,
    );
  }
}
