import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/status/data/repositories/robot_status_repository_impl.dart';

import '../../../../core/data/dtos/mqtt_messages/robot_status_dto.dart';
import '../../../../core/data/repositories/mqtt/mqtt_stream_repository.dart';
import '../../domain/entities/robot_status_entity.dart';
import '../../domain/repositories/robot_status_repository.dart';

class RobotStatusState extends Equatable {
  final RobotStatusEntity ssrStatus;
  final RobotStatusEntity spt1fStatus;
  final RobotStatusEntity spt3fStatus;

  const RobotStatusState({
    required this.ssrStatus,
    required this.spt1fStatus,
    required this.spt3fStatus,
  });

  factory RobotStatusState.initial() {
    final initialStatus = RobotStatusEntity(
      robotId: 'unknown',
      runState: RobotRunState.idle,
      driveState: RobotDriveState.stop,
      errorCode: 0,
      errorMsg: '',
      timestamp: DateTime.now(),
    );
    return RobotStatusState(
      ssrStatus: initialStatus,
      spt1fStatus: initialStatus,
      spt3fStatus: initialStatus,
    );
  }

  RobotStatusState copyWith({
    RobotStatusEntity? ssrStatus,
    RobotStatusEntity? spt1fStatus,
    RobotStatusEntity? spt3fStatus,
  }) {
    return RobotStatusState(
      ssrStatus: ssrStatus ?? this.ssrStatus,
      spt1fStatus: spt1fStatus ?? this.spt1fStatus,
      spt3fStatus: spt3fStatus ?? this.spt3fStatus,
    );
  }

  @override
  List<Object?> get props => [ssrStatus, spt1fStatus, spt3fStatus];
}

class RobotStatusNotifier extends StateNotifier<RobotStatusState> {
  final RobotStatusRepository _repository;

  RobotStatusNotifier(this._repository) : super(RobotStatusState.initial()) {
    _init();
  }

  void _init() {
    _repository.ssrStream.listen((status) {
      state = state.copyWith(ssrStatus: status);
    });

    _repository.spt1fStream.listen((status) {
      state = state.copyWith(spt1fStatus: status);
    });

    _repository.spt3fStream.listen((status) {
      state = state.copyWith(spt3fStatus: status);
    });
  }
}

final robotStatusProvider =
    StateNotifierProvider<RobotStatusNotifier, RobotStatusState>((ref) {
      final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
      final repository = RobotStatusRepositoryImpl(mqttStreamRepository);
      return RobotStatusNotifier(repository);
    });
