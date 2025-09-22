import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/repositories/mqtt_message_router_repository_impl.dart';

import '../network/mqtt/mqtt_provider.dart';

final mqttMessageRouterRepositoryProvider = Provider((ref) {
  final mqttService = ref.watch(mqttServiceProvider);

  final router = MqttMessageRouterRepositoryImpl(mqttService, ref);

  // ref.onDispose(() => router.dispose());

  return router;
});
