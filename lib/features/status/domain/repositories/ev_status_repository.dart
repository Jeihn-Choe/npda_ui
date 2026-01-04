import '../entities/ev_status_entity.dart';

// ✨ EV 상태 정보를 관리하는 Repository 인터페이스
abstract class EvStatusRepository {
  // 🚀 EV 상태 변경 사항을 실시간으로 구독하는 스트림
  Stream<EvStatusEntity> getEvStatusStream();
}
