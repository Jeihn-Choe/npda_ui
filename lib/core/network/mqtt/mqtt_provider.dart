import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mqtt_service.dart';
import 'mqtt_service_impl.dart';

final mqttServiceProvider = Provider<MqttService>((ref) {
  final mqttService = MqttServiceImpl();

  //앱이 종료될 때 MQTT 연결 해제
  ref.onDispose(() {
    mqttService.disconnect();
  });

  return mqttService;
});

/// MQTT 서비스를 사용하기 위해서는 무조건 provider에 접근해야함.
/// MQTT의 연결 상태, 메시지 스트림도 provider를 통해 접근하도록 강제해야 함.
/// 따라서 스트림도 provider로 노출
// MQTT 연결 상태 스트림 노출 StreamProvider
final mqttConnectionStateStreamProvider = StreamProvider<MqttState>((ref) {
  final mqttService = ref.watch(mqttServiceProvider);

  return mqttService.connectionStateStream;
});

// MQTT 수신 메시지 스트림 노출 StreamProvider
final mqttMessageStateStreamProvider = StreamProvider<ReceivedMqttMessage>((
  ref,
) {
  final mqttService = ref.watch(mqttServiceProvider);
  return mqttService.messageStream;
});
