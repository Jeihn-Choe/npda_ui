import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/usecase_providers.dart';
import '../../domain/usecases/outbound_1f_mission_usecase.dart';

/// OutboundMissionUseCase - 구현체 연결 Provider
final outbound1FMissionUseCaseProvider = Provider<Outbound1FMissionUseCase>((
  ref,
) {
  final mqttMessageRouterUseCase = ref.watch(mqttMessageRouterUseCaseProvider);
  final missionRepository = ref.watch(missionRepositoryProvider);
  final useCase = Outbound1FMissionUseCase(
    mqttMessageRouterUseCase,
    missionRepository,
  );
  useCase.startListening();
  ref.onDispose(() {
    useCase.dispose();
  });
  return useCase;
});
