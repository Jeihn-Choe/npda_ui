import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/core/providers/usecase_providers.dart';

import '../../domain/usecases/outbound_mission_usecase.dart';

/// OutboundMissionUseCase - 구현체 연결 Provider
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
