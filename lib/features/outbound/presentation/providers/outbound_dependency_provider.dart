import 'package:flutter_riverpod/flutter_riverpod.dart';
// ✨ 제거: 불필요한 import 제거
// import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_order_usecase.dart';

// ✨ 추가: Repository 관련 임포트
import 'package:npda_ui_flutter/features/outbound/domain/repositories/outbound_mission_repository.dart';
import 'package:npda_ui_flutter/features/outbound/data/repositories/outbound_mission_repository_impl.dart';
import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';


// ✨ 변경: OutboundOrderUseCase Provider 정의
// 중앙 Repository를 사용하므로, 별도의 Repository Provider는 필요 없음
final outboundOrderUseCaseProvider = Provider<OutboundOrderUseCase>((ref) {
  return OutboundOrderUseCase(ref);
});

// ✨ 추가: OutboundMissionRepository 제공자
final outboundMissionRepositoryProvider = Provider<OutboundMissionRepository>((ref) {
  final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
  return OutboundMissionRepositoryImpl(mqttStreamRepository);
});