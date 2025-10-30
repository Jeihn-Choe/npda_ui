import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/core/providers/usecase_providers.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_mission_usecase.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_order_usecase.dart';

// ✨ 변경: OutboundOrderUseCase Provider 정의
// 중앙 Repository를 사용하므로, 별도의 Repository Provider는 필요 없음
final outboundOrderUseCaseProvider = Provider<OutboundOrderUseCase>((ref) {
  return OutboundOrderUseCase(ref);
});

// ✨ 변경: OutboundMissionUseCase Provider 정의
final outboundMissionUseCaseProvider = Provider<OutboundMissionUseCase>((ref) {
  final mqttMessageRouterUseCase = ref.watch(mqttMessageRouterUseCaseProvider);
  final missionRepository = ref.watch(missionRepositoryProvider);
  final useCase = OutboundMissionUseCase(
    mqttMessageRouterUseCase,
    missionRepository,
  );
  useCase.startListening();
  ref.onDispose(() {
    useCase.dispose();
  });
  return useCase;
});