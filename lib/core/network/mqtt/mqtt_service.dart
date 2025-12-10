import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mqtt_service_impl.dart';

/// 연결 상태를 나타내는 enum
enum MqttState { connected, disconnected, connecting, error }

abstract class MqttService {
  /// 연결 상태 스트림
  Stream<MqttState> get connectionStateStream;

  /// 현재 연결 상태
  MqttState get connectionState;

  /// 수신된 메시지 스트림
  Stream<(String topic, String payload)> get mqttMessageStream;

  /// MQTT 브로커에 연결 - 콜하는 곳에서 파라미터 주입해줘야함
  Future<void> connect({
    required String clientId,
    required String broker,
    required int port,
  });

  /// 연결 종료
  void disconnect();

  /// 토픽 구독
  void subscribe(String topic);

  /// 토픽 구독 해제
  void unsubscribe(String topic);

  /// 메시지 발행 (필요시 사용)
  void publish(String topic, String message);
}

final mqttServiceProvider = Provider<MqttService>((ref) {
  final mqttService = MqttServiceImpl();

  //앱이 종료될 때 MQTT 연결 해제
  ref.onDispose(() {
    mqttService.disconnect();
  });

  return mqttService;
});

// MQTT 연결 상태 스트림 노출 StreamProvider
final mqttConnectionStateStreamProvider = StreamProvider<MqttState>((ref) {
  final mqttService = ref.watch(mqttServiceProvider);

  return mqttService.connectionStateStream;
});

// MQTT 수신 메시지 스트림 노출 StreamProvider
final mqttMessageStateStreamProvider =
    StreamProvider<(String topic, String payload)>((ref) {
      final mqttService = ref.watch(mqttServiceProvider);
      return mqttService.mqttMessageStream;
    });
