/// 연결 상태를 나타내는 enum
enum MqttState { connected, disconnected, connecting, error }

/// 수신된 메시지를 담을 클래스 (토픽과 데이터 관리)
class ReceivedMqttMessage {
  final String topic;
  final String payload;

  ReceivedMqttMessage({required this.topic, required this.payload});
}

abstract class MqttService {
  /// MQTT 브로커에 연결 시도
  /// 연결 성공/ 실패 여부는 connectionStateStream 으로 확인 가능
  Future<void> connect();

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
  Stream<ReceivedMqttMessage> get messageStream;
}
