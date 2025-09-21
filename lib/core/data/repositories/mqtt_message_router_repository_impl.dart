import 'dart:async';
import 'dart:convert';

import '../../network/mqtt/mqtt_service.dart';
import '../dtos/mqtt_receive_raw_dto.dart';

class MqttMessageRouterRepositoryImpl {
  final MqttService _mqttService;
  final InboundWorkListRepository _inboundWorkListRepository;

  late final StreamSubscription _mqttSubscription;

  MqttMessageRouterRepositoryImpl(
    this._mqttService,
    this._currentMissionListRepository,
  ) {
    _listenToMqttMessages();
  }

  void _listenToMqttMessages() {
    _mqttSubscription = _mqttService.messageStream.listen((message) {
      try {
        final decodedJson = jsonDecode(message.payload) as Map<String, dynamic>;
        final rawDto = MqttReceiveRawDto.fromJson(decodedJson);

        // switch 문으로 cmdId에 따라 각 리포지토리에 메시지 전달
        switch (rawDto.cmdId) {
          case "SM":
            break;

          case "SB":
            break;
        }
      } catch (e) {}
    });
  }
}
