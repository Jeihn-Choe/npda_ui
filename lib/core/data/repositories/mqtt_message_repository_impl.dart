import 'dart:async';

import 'package:npda_ui_flutter/core/domain/repositories/mqtt_message_repository.dart';
import 'package:npda_ui_flutter/core/network/mqtt/mqtt_service.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

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
    appLogger.d('[MqttMessageRepositoryImpl] MQTT 메시지 리포지토리 초기화');

    _connectionStateStreamSubscription = _mqttService.connectionStateStream
        .listen((state) {
          if (state == MqttState.connected) {
            appLogger.d('[MqttMessageRepositoryImpl] MQTT 연결됨, 메시지 수신 시작');

            _listenToMqttMessages();
          } else if (state == MqttState.disconnected) {
            appLogger.d('[MqttMessageRepositoryImpl] MQTT 연결 끊김, 메시지 수신 중지');
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

    _mqttSubscription = _mqttService.rawMqttMessageStream.listen((e) {
      try {
        final decodedJson = e as Map<String, dynamic>;

        final dto = ReceivedMqttMessageDto.fromJson(decodedJson);

        _mqttMessageDtoStreamController.add(dto);
        appLogger.d('[MqttMessageRepositoryImpl] MQTT 메시지 수신: $dto');
      } catch (e) {
        appLogger.e('[MqttMessageRepositoryImpl] MQTT 메시지 처리 중 오류 발생: $e');
      }
    });
  }
}
