import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/status/domain/repositories/robot_control_repository.dart';
import 'package:npda_ui_flutter/features/status/domain/usecases/robot_control_use_case.dart';

import '../../../../core/network/http/api_provider.dart';
import '../../data/repositories/robot_control_repository_impl.dart';

// [Repository Provider]
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
