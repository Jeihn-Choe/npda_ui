import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:npda_ui_flutter/core/config/app_config.dart';

import 'mqtt_service.dart';

class MqttServiceImpl implements MqttService {
  late MqttServerClient _client;
  final _connectionStateController = StreamController<MqttState>.broadcast();
  final _messageController = StreamController<RawMqttMessage>.broadcast();
  final List<String> _topics = [MqttConfig.mwTopic];

  MqttServiceImpl() {
    // MQTT 클라이언트 초기화
    _client = MqttServerClient(MqttConfig.broker, MqttConfig.clientId);
    _client.port = MqttConfig.port;

    // 클라이언트 ID 설정
    final clientId = MqttConfig.clientId;
    _client.clientIdentifier = clientId;

    // 연결 상태 관련 콜백 함수 설정.
    // _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.onSubscribeFail = _onSubscribeFail;

    //pong 메시지 수신 설정 (연결 유지 확인)
    _client.pongCallback = _pong;

    // 메시지 수신 콜백 함수 설정
    _client.updates?.listen(_onMessageReceived);
  }

  // void _onConnected() {
  //   logger('MQTT::Client Connection Success');
  //   _connectionStateController.add(MqttState.connected);
  //
  //   _client.updates!.listen(_onMessageReceived);
  // }

  void _onDisconnected() {
    _connectionStateController.add(MqttState.disconnected);
  }

  void _onSubscribed(String topic) {}

  void _onUnsubscribed(String? topic) {}

  void _onSubscribeFail(String topic) {}

  void _pong() {
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0];
    final pubMess = recMess.payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      pubMess.payload.message,
    );

    _messageController.add(
      RawMqttMessage(topic: recMess.topic, payload: payload),
    );
  }

  @override
  MqttState get connectionState {
    switch (_client.connectionStatus?.state) {
      case MqttConnectionState.connected:
        return MqttState.connected;
      case MqttConnectionState.connecting:
        return MqttState.connecting;
      case MqttConnectionState.disconnecting:
      case MqttConnectionState.disconnected:
      case MqttConnectionState.faulted:
        return MqttState.disconnected;
      default:
        return MqttState.error;
    }
  }

  @override
  Stream<MqttState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  Stream<RawMqttMessage> get rawMqttMessageStream => _messageController.stream;

  @override
  Future<void> connect() async {
    _connectionStateController.add(MqttState.connecting);
    try {
      await _client.connect();
    } on NoConnectionException catch (e) {
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    } on SocketException catch (e) {
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    } catch (e) {
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    }

    // 연결 상태 확인
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      _connectionStateController.add(MqttState.connected);

      // 연결 성공 후 message stream 리스너 설정 및 토픽 구독
      _client.updates!.listen(_onMessageReceived);
      for (final topic in _topics) {
        subscribe(topic);
      }
    } else {
      _client.disconnect();
      _connectionStateController.add(MqttState.error);
    }
  }

  @override
  void disconnect() {}

  @override
  void subscribe(String topic) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      _client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  @override
  void unsubscribe(String topic) {}

  @override
  void publish(String topic, String message) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    } else {}
  }
}
