import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../features/inbound/presentation/providers/inbound_providers.dart';
import '../../network/mqtt/mqtt_service.dart';
import '../dtos/mqtt_receive_raw_dto.dart';

class MqttMessageRouterRepositoryImpl {
  final MqttService _mqttService;
  final Ref _ref; // Ref 주입

  late final StreamSubscription _mqttSubscription;

  MqttMessageRouterRepositoryImpl(this._mqttService, this._ref) {
    logger("[MqttMessageRouterRepositoryImpl] MQTT 메시지 라우터 초기화");

    _listenToMqttMessages();
  }

  void _listenToMqttMessages() {
    logger("===== MQTT 메시지 수신 리스너 ==== ");

    _mqttSubscription = _mqttService.messageStream.listen((message) {
      try {
        final decodedJson = jsonDecode(message.payload) as Map<String, dynamic>;
        final rawDto = MqttReceiveRawDto.fromJson(decodedJson);

        logger("===== 케이스문 분기 전 ==== ");
        // switch 문으로 cmdId에 따라 각 리포지토리에 메시지 전달
        switch (rawDto.cmdId) {
          case "SM":
            logger("===== SM케이스문분기 ==== ");

            //ref 를 사용하여 inbound provier 접근
            final inboundRepo = _ref.read(
              currentInboundMissionRepositoryProvider,
            );

            logger("===== 미션 업데이트 요청 ==== ");
            // 해당 리포지토리의 updateInboundMissionList 메서드 호출
            inboundRepo.updateInboundMissionList(rawDto.payload);

            break;

          case "SB":
            break;
        }
      } catch (e) {}
    });
  }

  void dispose() {
    _mqttSubscription.cancel();
  }
}
