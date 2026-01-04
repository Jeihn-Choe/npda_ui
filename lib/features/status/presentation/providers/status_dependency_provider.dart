import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/status/domain/repositories/robot_control_repository.dart';
import 'package:npda_ui_flutter/features/status/domain/usecases/robot_control_use_case.dart';

import '../../../../core/data/repositories/mqtt/mqtt_stream_repository.dart';
import '../../../../core/network/http/api_provider.dart';
import '../../data/repositories/ev_control_repository_impl.dart';
import '../../data/repositories/ev_status_repository_impl.dart';
import '../../data/repositories/robot_control_repository_impl.dart';
import '../../domain/entities/ev_status_entity.dart';
import '../../domain/repositories/ev_control_repository.dart';
import '../../domain/repositories/ev_status_repository.dart';
import '../../domain/usecases/ev_control_use_case.dart';

// [Repository Provider]
// ✨ EV 상태 Repository Provider 추가
final evStatusRepositoryProvider = Provider<EvStatusRepository>((ref) {
  final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
  return EvStatusRepositoryImpl(mqttStreamRepository);
});

// ✨ EV 제어 Repository Provider 추가
final evControlRepositoryProvider = Provider<EvControlRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EvControlRepositoryImpl(apiService);
});

final robotControlRepositoryProvider = Provider<RobotControlRepository>((ref) {
  //1. Impl 주입
  final apiService = ref.watch(apiServiceProvider);
  return RobotControlRepositoryImpl(apiService);
  //2. Mock 주입
  // return RobotControlRepositoryMock();
});

// [UseCase Provider]
final robotControlUseCaseProvider = Provider<RobotControlUseCase>((ref) {
  final repository = ref.watch(robotControlRepositoryProvider);
  return RobotControlUseCase(repository);
});

// ✨ EV 제어 UseCase Provider 추가
final evControlUseCaseProvider = Provider<EvControlUseCase>((ref) {
  final repository = ref.watch(evControlRepositoryProvider);
  return EvControlUseCase(repository);
});

// [Stream Provider]
// 🚀 UI에서 EV 상태를 실시간으로 구독하기 위한 StreamProvider
final evStatusStreamProvider = StreamProvider<EvStatusEntity>((ref) {
  final repository = ref.watch(evStatusRepositoryProvider);
  return repository.getEvStatusStream();
});
