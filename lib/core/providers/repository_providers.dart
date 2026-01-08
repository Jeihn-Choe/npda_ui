import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';

import '../data/repositories/mission/mission_repository_impl.dart';
import '../data/repositories/order/order_repository_mock.dart';
import '../domain/repositories/order_repository.dart';
import '../network/http/api_provider.dart';

/// 앱 전역에서 MissionRepository를 제공하는 Provider
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return MissionRepositoryImpl(apiService);
});

/// 앱 전역에서 OrderRepository를 제공하는 Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  // 실제 API 사용 (Impl) 시 주석 해제
  // final apiService = ref.watch(apiServiceProvider);
  // return OrderRepositoryImpl(apiService);

  // Mock 사용 시 주석 해제
  return OrderRepositoryMock();
});
