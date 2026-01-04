// ✨ EV(엘리베이터) 상태 제어(보고)를 위한 Repository 인터페이스
abstract class EvControlRepository {
  // 🚀 EV 상태 업데이트 (메인/서브 상태를 동시에 보고)
  Future<void> updateEvStatus({
    required bool isMainError,
    required bool isSubError,
  });
}
