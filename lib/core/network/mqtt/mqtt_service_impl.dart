import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import 'mqtt_service.dart';

class MqttServiceImpl implements MqttService {
  MqttServerClient? _client;

  ///Record 사용
  final _messageController = StreamController<(String, String)>.broadcast();
  final _connectionStateController = StreamController<MqttState>.broadcast();

  MqttServiceImpl();

  @override
  Stream<MqttState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  Stream<(String, String)> get mqttMessageStream => _messageController.stream;

  @override
  MqttState get connectionState {
    if (_client == null) return MqttState.disconnected;

    switch (_client!.connectionStatus?.state) {
      case MqttConnectionState.connected:
        return MqttState.connected;
      case MqttConnectionState.connecting:
        return MqttState.connecting;
      case MqttConnectionState.disconnected:
        return MqttState.disconnected;
      case MqttConnectionState.faulted:
        return MqttState.error;
      default:
        return MqttState.disconnected;
    }
  }

  @override
  Future<void> connect({
    required String clientId,
    required String broker,
    required int port,
  }) async {
    ///이미 연결되어있으면 끊고 다시 연결
    if (_client != null &&
        _client!.connectionStatus?.state == MqttConnectionState.connected) {
      disconnect();
    }

    /// 연결 시도 중 상태 알림
    _connectionStateController.add(MqttState.connecting);

    /// 클라이언트 생성 및 기본 설정
    _client = MqttServerClient(broker, clientId);
    _client!.port = port;
    _client!.keepAlivePeriod = 20;

    /// 콜백 함수 연결
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    /// 연결 옵션 설정 (Clean Session)
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    /// 연결 시도
    try {
      await _client!.connect();
    } catch (e) {
      appLogger.e('MQTT::클라이언트 예외 - $e');
      _client!.disconnect();
    }

    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _connectionStateController.add(MqttState.connected);

      _client!.updates!.listen(_onMessageReceived);
    } else {
      appLogger.e('MQTT::연결실패 - status: ${_client?.connectionStatus}');
      _connectionStateController.add(MqttState.error);
      disconnect();
    }
  }

  @override
  void disconnect() {
    _client?.disconnect();
  }

  @override
  void subscribe(String topic) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    } else {
      appLogger.w('MQTT::구독 실패 - 클라이언트가 연결되어 있지 않음');
    }
  }

  @override
  void unsubscribe(String topic) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.unsubscribe(topic);
    }
  }

  @override
  void publish(String topic, String message) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } else {
      appLogger.w('MQTT::발행 실패 - 클라이언트가 연결되어 있지 않음');
    }
  }

  void _onConnected() {
    appLogger.i('MQTT::연결됨');
    _connectionStateController.add(MqttState.connected);
  }

  void _onDisconnected() {
    appLogger.i('MQTT::연결 해제됨');
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(MqttState.disconnected);
    }
  }

  void _onSubscribed(String topic) {
    appLogger.i('MQTT::구독됨 - topic: $topic');
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? c) {
    if (c == null || c.isEmpty) return;

    final recMess = c[0];
    final pubMess = recMess.payload as MqttPublishMessage;

    final payload = MqttPublishPayload.bytesToStringAsString(
      pubMess.payload.message,
    );

    _messageController.add((recMess.topic, payload));

    appLogger.i('MQTT::메시지 수신 - topic: ${recMess.topic} , payload: $payload');
  }

  void dispose() {
    _messageController.close();
    _connectionStateController.close();
  }
}
