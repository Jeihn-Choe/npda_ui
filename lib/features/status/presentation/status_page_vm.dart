import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_po_entity.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_po_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_po_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound_1f/domain/entities/outbound_1f_po_entity.dart';
import 'package:npda_ui_flutter/features/status/presentation/providers/robot_status_provider.dart';

import '../../outbound/domain/entities/outbound_po_entity.dart';
import '../domain/entities/robot_status_entity.dart';

class StatusState {
  final bool isMainLiftAvailable;
  final bool isSubLiftAvailable;
  final List<InboundPoEntity> inboundPoList;
  final List<OutboundPoEntity> outboundPoList;
  final List<Outbound1fPoEntity> outbound1FPoList;

  final RobotStatusEntity ssrStatus;
  final RobotStatusEntity spt1fStatus;
  final RobotStatusEntity spt3fStatus;

  StatusState({
    required this.isMainLiftAvailable,
    required this.isSubLiftAvailable,
    this.inboundPoList = const [],
    this.outboundPoList = const [],
    this.outbound1FPoList = const [],

    required this.ssrStatus,
    required this.spt1fStatus,
    required this.spt3fStatus,
  });

  StatusState copyWith({
    bool? isMainLiftAvailable,
    bool? isSubLiftAvailable,
    List<InboundPoEntity>? inboundPoList,
    List<OutboundPoEntity>? outboundPoList,
    List<Outbound1fPoEntity>? outbound1FPoList,

    RobotStatusEntity? ssrStatus,
    RobotStatusEntity? spt1fStatus,
    RobotStatusEntity? spt3fStatus,
  }) {
    return StatusState(
      isMainLiftAvailable: isMainLiftAvailable ?? this.isMainLiftAvailable,
      isSubLiftAvailable: isSubLiftAvailable ?? this.isSubLiftAvailable,

      inboundPoList: inboundPoList ?? this.inboundPoList,
      outboundPoList: outboundPoList ?? this.outboundPoList,
      outbound1FPoList: outbound1FPoList ?? this.outbound1FPoList,

      ssrStatus: ssrStatus ?? this.ssrStatus,
      spt1fStatus: spt1fStatus ?? this.spt1fStatus,
      spt3fStatus: spt3fStatus ?? this.spt3fStatus,
    );
  }
}

class StatusPageVM extends StateNotifier<StatusState> {
  final Ref _ref;

  StatusPageVM(this._ref)
    : super(
        StatusState(
          isMainLiftAvailable: true,
          isSubLiftAvailable: true,

          inboundPoList: _ref.read(inboundPoListProvider).poList,
          outboundPoList: _ref.read(outboundPoListProvider).poList,
          outbound1FPoList: [],

          // _ref.read(outbound1FPoListProvider).poList,
          ssrStatus: _ref.read(robotStatusProvider).ssrStatus,
          spt1fStatus: _ref.read(robotStatusProvider).spt1fStatus,
          spt3fStatus: _ref.read(robotStatusProvider).spt3fStatus,
        ),
      ) {
    _init();
  }

  void _init() {
    // inboundPoListProvider 구독/상태 동기화
    _ref.listen<InboundPoListState>(inboundPoListProvider, (previous, next) {
      state = state.copyWith(inboundPoList: next.poList);
    });
    // outboundPoListProvider 구독/상태 동기화
    _ref.listen<OutboundPoListState>(outboundPoListProvider, (previous, next) {
      state = state.copyWith(outboundPoList: next.poList);
    });

    // outbound1FPoListProvider 구독/상태 동기화
    // _ref.listen<OutboundPoListState>(outbound1FPoListProvider, (
    //   previous,
    //   next,
    // ) {
    //   if (previous?.poList != next.poList) {
    //     state = state.copyWith(outbound1FPoList: next.poList);
    //   }
    // });

    // robotStatusProvider 구독/상태 동기화
    _ref.listen<RobotStatusState>(robotStatusProvider, (previous, next) {
      state = state.copyWith(
        ssrStatus: next.ssrStatus,
        spt1fStatus: next.spt1fStatus,
        spt3fStatus: next.spt3fStatus,
      );
    });

    // 초기 로드 (이미 데이터가 있을 경우를 대비)
    // final currentPoState = _ref.read(inboundPoListProvider);
    // if (currentPoState.poList.isNotEmpty) {
    //   state = state.copyWith(inboundPoList: currentPoState.poList);
    // }
  }
}

final statusPageVMProvider = StateNotifierProvider<StatusPageVM, StatusState>((
  ref,
) {
  return StatusPageVM(ref);
});
