import 'dart:async';
import 'dart:convert';

import 'package:npda_ui_flutter/core/domain/entities/sb_entity.dart';
import 'package:npda_ui_flutter/core/domain/entities/sm_entity.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../repositories/mqtt_message_repository.dart';

class MqttMessageRouterUseCase {
  final MqttMessageRepository _mqttMessageRepository;
  StreamSubscription? _mqttSubscription;

  /// cmdId 별로 구분해줄 StreamController를 정의.
  /// [SM]
  final _smStreamController = StreamController<List<SmEntity>>.broadcast();

  /// [SB]
  final _sbStreamController = StreamController<List<SbEntity>>.broadcast();

  /// 외부에서 구독할 수 있도록 cmdId 별 스트림을 노출하는 getter 정의

  Stream<List<SmEntity>> get smStream => _smStreamController.stream;

  Stream<List<SbEntity>> get sbStream => _sbStreamController.stream;

  MqttMessageRouterUseCase(this._mqttMessageRepository);

  void startListening() {
    _mqttSubscription ??= _mqttMessageRepository.mqttMessageDtoStream.listen((
      message,
    ) {
      appLogger.d("UseCase에서 mqttMessageDtoStream 수신");
      appLogger.d(message.toString());
      switch (message.cmdId) {
        case 'SM':
          try {
            final smEntities = _parseSmPayload(message.payload);
            appLogger.d("파싱된 SM 엔티티 개수: ${smEntities.length}");
            _smStreamController.add(smEntities);
          } catch (e) {
            appLogger.e("SM 페이로드 파싱 오류: $e");
          }

          break;
        case 'SB':
          try {
            final sbEntities = _parseSbPayload(message.payload);
            appLogger.d("파싱된 SB 엔티티 개수: ${sbEntities.length}");
            _sbStreamController.add(sbEntities);
          } catch (e) {
            appLogger.e("SB 페이로드 파싱 오류: $e");
          }

          break;
        default:
          appLogger.d("정의되지 않은 cmdId : ${message.cmdId}");
          break;
      }
    });
  }

  void dispose() {
    _mqttSubscription?.cancel();
    _mqttSubscription = null;

    _smStreamController.close();
    _sbStreamController.close();

    _mqttMessageRepository.dispose();
  }

  List<SmEntity> _parseSmPayload(dynamic payload) {
    if (payload is List) {
      try {
        return payload
            .map((item) => SmEntity.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        appLogger.d("SM 페이로드 파싱 중 오류 발생: $e");
        return [];
      }
    } else {
      throw FormatException("Invalid SM payload format");
    }
  }

  List<SbEntity> _parseSbPayload(String payloadJson) {
    final decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('payload') &&
        decoded['payload'] is List) {
      final List<dynamic> sendBinListJson = decoded['payload'] as List<dynamic>;

      return sendBinListJson
          .map((item) => SbEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw FormatException("Invalid SB payload format");
    }
  }
}
