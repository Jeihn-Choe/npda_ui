import 'dart:async';
import 'dart:convert';

import 'package:npda_ui_flutter/core/domain/repositories/mqtt_message_repository.dart';
import 'package:npda_ui_flutter/core/network/mqtt/mqtt_service.dart';

import '../dtos/received_mqtt_message_dto.dart';

class MqttMessageRepositoryImpl extends MqttMessageRepository {
  final MqttService _mqttService;

  StreamSubscription? _connectionStateStreamSubscription;
  StreamSubscription? _mqttSubscription;

  /// DTO로 변환된 MQTT 메시지를 최종 브로드캐스트하기 위한 스트림을 컨트롤하는 컨트롤러
  final _mqttMessageDtoStreamController =
      StreamController<ReceivedMqttMessageDto>.broadcast();

  /// 스트림 컨트롤러에서 stream을 꺼내서 messageDtoStream으로 제공.
  @override
  Stream<ReceivedMqttMessageDto> get mqttMessageDtoStream =>
      _mqttMessageDtoStreamController.stream;

  @override
  void dispose() {
    // TODO: implement dispose
  }

  MqttMessageRepositoryImpl(this._mqttService) {
    _connectionStateStreamSubscription = _mqttService.connectionStateStream
        .listen((state) {
          if (state == MqttState.connected) {
            _listenToMqttMessages();
          } else if (state == MqttState.disconnected) {
            _mqttSubscription?.cancel();
            _mqttSubscription = null;
          }
        });

    if (_mqttService.connectionState == MqttState.connected) {
      _listenToMqttMessages();
    }
  }

  void _listenToMqttMessages() {
    if (_mqttSubscription != null) {
      // 이미 구독 중인 경우 중복 구독 방지
      return;
    }

    _mqttSubscription = _mqttService.rawMqttMessageStream.listen((rawMessage) {
      try {
        /// 수신된 RawMqttMessage 객체에서 payload 추출
        final jsonString = rawMessage.payload;

        /// JSON 문자열을 DTO로 변환
        final decodedJson = json.decode(jsonString) as Map<String, dynamic>;

        final dto = ReceivedMqttMessageDto.fromJson(decodedJson);

        _mqttMessageDtoStreamController.add(dto);
      } catch (e) {
        // JSON 파싱 실패 시 무시
      }
    });
  }
}
