import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/usecases/mqtt_message_router_usecase.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

/// 앱 전역에서 MqttMessageRouterUseCase를 주입하기 위한 Provider
final mqttMessageRouterUseCaseProvider = Provider<MqttMessageRouterUseCase>((
  ref,
) {
  final mqttMessageRepository = ref.watch(mqttMessageRepositoryProvider);
  final useCase = MqttMessageRouterUseCase(mqttMessageRepository);

  // 앱 시작 시점에 mqtt message 리스닝 시작
  useCase.startListening();

  ref.onDispose(() {
    appLogger.d(" [mqttMessageRouterUseCaseProvider] MQTT 메시지 라우터 유스케이스 종료 ");
    useCase.dispose();
  });

  return useCase;
});
