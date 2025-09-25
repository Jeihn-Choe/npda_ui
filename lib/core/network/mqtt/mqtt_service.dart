/// 연결 상태를 나타내는 enum
enum MqttState { connected, disconnected, connecting, error }

/// 수신된 메시지를 담을 클래스 (토픽과 데이터 관리)
class RawMqttMessage {
  final String topic;
  final String payload;

  RawMqttMessage({required this.topic, required this.payload});
}

abstract class MqttService {
  /// MQTT 브로커에 연결 시도
  Future<void> connect();

  /// MQTT 연결 상태 확인
  MqttState get connectionState;

  /// MQTT 브로커와의 연결 종료
  void disconnect();

  /// 토픽 구독
  void subscribe(String topic);

  /// 토픽 구독 해제
  void unsubscribe(String topic);

  /// 메시지 발행
  void publish(String topic, String message);

  /// 연결 상태 스트림
  Stream<MqttState> get connectionStateStream;

  /// 수신된 메시지 스트림
  Stream<RawMqttMessage> get rawMqttMessageStream;
}
