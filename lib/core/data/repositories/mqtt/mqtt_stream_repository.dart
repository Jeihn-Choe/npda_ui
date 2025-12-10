import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/dtos/mqtt_messages/es_dto.dart';
import 'package:npda_ui_flutter/core/data/dtos/mqtt_messages/po_dto.dart';
import 'package:npda_ui_flutter/core/network/mqtt/mqtt_service.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../config/app_config.dart';
import '../../dtos/mqtt_messages/mw_unwrap_cmd_id_dto.dart';
import '../../dtos/mqtt_messages/robot_status_dto.dart';
import '../../dtos/mqtt_messages/sm_dto.dart';

class MqttStreamRepository {
  late final MqttService _mqttService;

  /// 스트림 컨트롤러 정의

  // MW.NPDA
  final _smController = StreamController<List<SmDto>>.broadcast();
  final _poController = StreamController<List<PoDto>>.broadcast();
  final _esController = StreamController<List<EsDto>>.broadcast();

  // mid.sol
  final _ssrController = StreamController<RobotStatusDto>.broadcast();
  final _spt1FController = StreamController<RobotStatusDto>.broadcast();
  final _spt3FController = StreamController<RobotStatusDto>.broadcast();

  /// 외부로 노출할 스트림 getter 정의
  Stream<List<SmDto>> get smStream => _smController.stream;

  Stream<List<PoDto>> get poStream => _poController.stream;

  Stream<List<EsDto>> get esStream => _esController.stream;

  Stream<RobotStatusDto> get ssrStream => _ssrController.stream;

  Stream<RobotStatusDto> get spt1FStream => _spt1FController.stream;

  Stream<RobotStatusDto> get spt3FStream => _spt3FController.stream;

  /// 초기화 및 연결
  MqttStreamRepository(this._mqttService) {
    _initialize();
  }

  void _initialize() {
    /// 연결 상태 확인
    _mqttService.connectionStateStream.listen((state) {
      if (state == MqttState.connected) {
        _onConnected();
      }
    });

    /// cmdId 토픽별 구분
    _distributeTopic();

    /// MQTT 연결 시도
    _connect();
  }

  Future<void> _connect() async {
    try {
      await _mqttService.connect(
        clientId: MqttConfig.clientId,
        broker: MqttConfig.broker,
        port: MqttConfig.port,
      );
    } catch (e) {
      appLogger.e("❌ MQTT 연결 실패: $e");
    }
  }

  void _onConnected() {
    appLogger.d("✅ MQTT 연결, 토픽 구독 시작");

    /// 토픽 구독
    _mqttService.subscribe(MqttConfig.mwTopic); // "MW.NPDA"

    _mqttService.subscribe(MqttConfig.ssrStatusTopic); // SSR
    _mqttService.subscribe(MqttConfig.spt1FStatusTopic); // SPT 1F
    _mqttService.subscribe(MqttConfig.spt3FStatusTopic); // SPT 3F
  }

  void _distributeTopic() {
    _mqttService.mqttMessageStream.listen((message) {
      final (topic, jsonString) = message;

      if (topic == MqttConfig.mwTopic) {
        _handleMwMessage(jsonString);
      }

      if (topic == MqttConfig.ssrStatusTopic ||
          topic == MqttConfig.spt1FStatusTopic ||
          topic == MqttConfig.spt3FStatusTopic) {
        _handleRobotStatusMessage(jsonString);
      }
    });
  }

  void _handleMwMessage(String jsonString) {
    try {
      final decoded =
          json.decode(jsonString)
              as Map<String, dynamic>; // JSON 문자열을 Map으로 디코딩
      final envelope = MwUnwrapCmdIdDto.fromJson(
        decoded,
      ); // MwUnwrapCmdIdDto 변환 cmdId, payload 추출 MAP 형태

      switch (envelope.cmdId) {
        case 'SM':
          final payloadList = decoded['payload'] as List;
          final smData = payloadList.map((e) => SmDto.fromJson(e)).toList();
          _smController.add(smData); // smStream으로 publish
          break;
        case 'PO':
          final payloadList = decoded['payload'] as List;
          final poData = payloadList.map((e) => PoDto.fromJson(e)).toList();
          _poController.add(poData);
          break;
        case 'ES':
          final payloadList = decoded['payload'] as List;
          final esData = payloadList.map((e) => EsDto.fromJson(e)).toList();
          _esController.add(esData);
          break;
        default:
          // 알 수 없는 cmdId 무시
          break;
      }
    } catch (e) {
      // JSON 파싱 실패 시 무시
    }
  }

  void _handleRobotStatusMessage(String jsonString) {
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final robotStatus = RobotStatusDto.fromJson(decoded);

      switch (robotStatus.robotId) {
        case 'SSR':
          _ssrController.add(robotStatus);
          break;
        case 'SPT_1F':
          _spt1FController.add(robotStatus);
          break;
        case 'SPT_3F':
          _spt3FController.add(robotStatus);
          break;
        default:
          // 알 수 없는 robotId 무시
          break;
      }
    } catch (e) {
      // JSON 파싱 실패 시 무시
    }
  }
}

/// MqttStreamRepository 전역 제공 Provider
final mqttStreamRepositoryProvider = Provider<MqttStreamRepository>((ref) {
  final mqttService = ref.watch(mqttServiceProvider);
  return MqttStreamRepository(mqttService);
});
