import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_mission_entity.dart';

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
