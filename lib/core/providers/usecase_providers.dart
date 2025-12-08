import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';

/// 앱 전역에서 MqttMessageRouterUseCase를 주입하기 위한 Provider
final mqttMessageRouterUseCaseProvider = Provider<MqttMessageRouterUseCase>((
  ref,
) {
  final mqttMessageRepository = ref.watch(mqttMessageRepositoryProvider);
  final useCase = MqttMessageRouterUseCase(mqttMessageRepository);

  // 앱 시작 시점에 mqtt message 리스닝 시작
  useCase.startListening();

  ref.onDispose(() {
    useCase.dispose();
  });

  return useCase;
});
