import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/dtos/received_mqtt_message_dto.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mqtt_message_repository.dart';
import 'package:npda_ui_flutter/core/network/mqtt/mqtt_provider.dart';

import '../data/repositories/mission_repository_impl.dart';
import '../data/repositories/mqtt_message_repository_impl.dart';
import '../data/repositories/order_repository_impl.dart';
import '../data/repositories/order_repository_mock.dart';
import '../domain/repositories/order_repository.dart';
import '../network/http/api_provider.dart';

/// 앱 전역에서 MissionRepository를 제공하는 Provider
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return MissionRepositoryImpl(apiService);
});

/// 앱 전역에서 MqttMessageRepository를 제공하는 Provider
final mqttMessageRepositoryProvider = Provider<MqttMessageRepository>((ref) {
  final mqttService = ref.watch(mqttServiceProvider);
  return MqttMessageRepositoryImpl(mqttService);
});

/// 앱 전역에서 MqttMessageRepository 가 제공하는 DTO 스트림을 구독하는 StreamProvider

final mqttMessageDtoStreamProvider = StreamProvider<ReceivedMqttMessageDto>((
  ref,
) {
  /// ReceivedMqttMessageDto 스트림을 구독
  final repository = ref.watch(mqttMessageRepositoryProvider);

  /// repository의 mqttMessageDtoStream을 return
  return repository.mqttMessageDtoStream;
});

/// 앱 전역에서 OrderRepository를 제공하는 Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  // ✨ 변경: Mock Repository를 반환하도록 수정
  return OrderRepositoryMock();

  // ✨ 변경: 실제 API 사용 시 아래 코드로 전환
  // final apiService = ref.watch(apiServiceProvider);
  // return OrderRepositoryImpl(apiService);
});
