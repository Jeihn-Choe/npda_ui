import 'package:npda_ui_flutter/core/data/dtos/received_mqtt_message_dto.dart';

abstract class MqttMessageRepository {
  /// MQTT 메시지를 실시간으로 제공하는 스트림
  Stream<ReceivedMqttMessageDto> get mqttMessageDtoStream;

  /// 리소스 해제 메소드
  void dispose();
}
