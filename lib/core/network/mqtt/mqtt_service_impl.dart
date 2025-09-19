import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import 'mqtt_service.dart';

class MqttServiceImpl implements MqttService {
  late MqttServerClient _client;
  final _connectionStateController = StreamController<MqttState>.broadcast();

  final _messageController = StreamController<ReceivedMqttMessage>.broadcast();

  MqttServiceImpl() {
    //TODO : config 파일에서 호스트와 포트 가져오도록 수정해야함. 일단 그냥 하드코딩
    _client = MqttServerClient('http://192.168.3.115', '');
    _client.port = 1883;

    // 클라이언트 ID 설정
    final clientId = 'npda_client_${DateTime.now().millisecondsSinceEpoch}';
    _client.clientIdentifier = clientId;

    // 연결 상태 관련 콜백 함수 설정.
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.onSubscribeFail = _onSubscribeFail;

    //pong 메시지 수신 설정 (연결 유지 확인)
    _client.pongCallback = _pong;

    // 메시지 수신 콜백 함수 설정
    _client.updates?.listen(_onMessageReceived);
  }

  void _onConnected() {
    logger('MQTT::Client Connection Success');
    _connectionStateController.add(MqttState.connected);
  }

  void _onDisconnected() {
    logger('MQTT::Client Disconnected');
    _connectionStateController.add(MqttState.disconnected);
  }

  void _onSubscribed(String topic) {
    logger('MQTT::Subscription confirmed for topic $topic');
  }

  void _onUnsubscribed(String? topic) {
    logger('MQTT::Unsubscribed from topic $topic');
  }

  void _onSubscribeFail(String topic) {
    logger('MQTT::Failed to subscribe $topic');
  }

  void _pong() {
    logger('MQTT::Ping response client callback invoked');
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final MqttPublishMessage message = c![0].payload as MqttPublishMessage;
    final String topic = c[0].topic;
    final String payload = MqttPublishPayload.bytesToStringAsString(
      message.payload.message,
    );

    _messageController.add(ReceivedMqttMessage(topic: topic, payload: payload));
  }

  @override
  Stream<MqttState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  Stream<ReceivedMqttMessage> get messageStream => _messageController.stream;

  @override
  Future<void> connect() async {
    _connectionStateController.add(MqttState.connecting);
    try {
      logger("MQTT::Connecting to MQTT broker...");
      await _client.connect();
    } on NoConnectionException catch (e) {
      logger('MQTT::Client exception - $e');
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    } on SocketException catch (e) {
      logger('MQTT::Socket exception - $e');
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    } catch (e) {
      logger('MQTT::Unexpected exception - $e');
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    }

    // 연결 상태 확인
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      logger("MQTT::Connected to MQTT broker");
      _connectionStateController.add(MqttState.connected);
    } else {
      logger(
        "MQTT::ERROR: MQTT client connection failed - disconnecting, status is ${_client.connectionStatus}",
      );
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    }
  }

  @override
  void disconnect() {}

  @override
  void subscribe(String topic) {}

  @override
  void unsubscribe(String topic) {}

  @override
  void publish(String topic, String message) {}
}
