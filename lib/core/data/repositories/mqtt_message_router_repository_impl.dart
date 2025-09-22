import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/dtos/mqtt_receive_raw_dto.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../features/inbound/presentation/providers/inbound_providers.dart';
import '../../network/mqtt/mqtt_service.dart';

class MqttMessageRouterRepositoryImpl {
  final MqttService _mqttService;
  final Ref _ref; // Ref 주입

  StreamSubscription? _connectionStateStreamSubscription;
  StreamSubscription? _mqttSubscription;

  MqttMessageRouterRepositoryImpl(this._mqttService, this._ref) {
    logger("[MqttMessageRouterRepositoryImpl] MQTT 메시지 라우터 초기화");

    if (_mqttService.connectionStateStream == MqttState.connected) {
      _listenToMqttMessages();
    }

    _connectionStateStreamSubscription = _mqttService.connectionStateStream
        .listen((state) {
          if (state == MqttState.connected) {
            _listenToMqttMessages();
          } else if (state == MqttState.disconnected) {
            _mqttSubscription?.cancel();
            _mqttSubscription = null;
          }
        });
  }

  void _listenToMqttMessages() {
    if (_mqttSubscription != null) {
      // 이미 구독 중인 경우 중복 구독 방지
      return;
    }

    _mqttSubscription = _mqttService.messageStream.listen((message) {
      try {
        final decodedJson = jsonDecode(message.payload) as Map<String, dynamic>;
        final rawDto = MqttReceiveRawDto.fromJson(decodedJson);

        // switch 문으로 cmdId에 따라 각 리포지토리에 메시지 전달
        switch (rawDto.cmdId) {
          case "SM":
            final inboundRepo = _ref.read(
              currentInboundMissionRepositoryProvider,
            );

            final subMissionList = rawDto.payload as List<dynamic>;
            inboundRepo.updateInboundMissionList(subMissionList);

            break;

          case "SB":
            break;
        }
      } catch (e) {
        logger("Error processing MQTT message: $e");
      }
    });
  }

  //
  // void dispose() {
  //   _mqttSubscription.cancel();
  // }
}
