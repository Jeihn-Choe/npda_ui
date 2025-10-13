import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_mission_entity.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_mission_usecase.dart';

import 'outbound_dependency_provider.dart';

class OutboundMissionListState {
  final bool isLoading;
  final String? errorMessage;
  final List<OutboundMissionEntity> missions;

  OutboundMissionListState({
    this.isLoading = false,
    this.errorMessage,
    this.missions = const [],
  });

  OutboundMissionListState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<OutboundMissionEntity>? missions,
  }) {
    return OutboundMissionListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      missions: missions ?? this.missions,
    );
  }
}

class OutboundMissionListNotifier
    extends StateNotifier<OutboundMissionListState> {
  final OutboundMissionUseCase _missionUseCase;
  StreamSubscription? _missionSubscription;

  OutboundMissionListNotifier(this._missionUseCase)
    : super(OutboundMissionListState()) {
    _listenToMissions();
  }

  void _listenToMissions() {
    state = state.copyWith(isLoading: true);

    _missionSubscription = _missionUseCase.outboundMissionStream.listen(
      (missions) {
        state = state.copyWith(
          missions: missions,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  @override
  void dispose() {
    _missionSubscription?.cancel();
    super.dispose();
  }
}

final outboundMissionListProvider =
    StateNotifierProvider<
      OutboundMissionListNotifier,
      OutboundMissionListState
    >((ref) {
      final missionUseCase = ref.watch(outboundMissionUseCaseProvider);

      return OutboundMissionListNotifier(missionUseCase);
    });
