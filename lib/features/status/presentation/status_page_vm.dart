import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_po_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_po_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/providers/outbound_1f_po_list_provider.dart';
import 'package:npda_ui_flutter/features/status/presentation/providers/robot_status_provider.dart';
import 'package:npda_ui_flutter/features/status/presentation/providers/status_dependency_provider.dart';

import '../domain/entities/ev_status_entity.dart';
import '../domain/entities/robot_status_entity.dart';

class StatusState {
  final bool isMainLiftAvailable;
  final bool isSubLiftAvailable;
  final InboundPoListState inboundPoListState;
  final OutboundPoListState outboundPoListState;
  final Outbound1fPoListState outbound1FPoListState;

  final RobotStatusEntity ssrStatus;
  final RobotStatusEntity spt1fStatus;
  final RobotStatusEntity spt3fStatus;

  StatusState({
    required this.isMainLiftAvailable,
    required this.isSubLiftAvailable,
    required this.inboundPoListState,
    required this.outboundPoListState,
    required this.outbound1FPoListState,

    required this.ssrStatus,
    required this.spt1fStatus,
    required this.spt3fStatus,
  });

  StatusState copyWith({
    bool? isMainLiftAvailable,
    bool? isSubLiftAvailable,
    InboundPoListState? inboundPoList,
    OutboundPoListState? outboundPoList,
    Outbound1fPoListState? outbound1FPoList,

    RobotStatusEntity? ssrStatus,
    RobotStatusEntity? spt1fStatus,
    RobotStatusEntity? spt3fStatus,
  }) {
    return StatusState(
      isMainLiftAvailable: isMainLiftAvailable ?? this.isMainLiftAvailable,
      isSubLiftAvailable: isSubLiftAvailable ?? this.isSubLiftAvailable,

      inboundPoListState: inboundPoList ?? this.inboundPoListState,
      outboundPoListState: outboundPoList ?? this.outboundPoListState,
      outbound1FPoListState: outbound1FPoList ?? this.outbound1FPoListState,

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

          inboundPoListState: _ref.read(inboundPoListProvider),
          outboundPoListState: _ref.read(outboundPoListProvider),
          outbound1FPoListState: _ref.read(outbound1fPoListProvider),

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
      state = state.copyWith(inboundPoList: next);
    });
    // outboundPoListProvider 구독/상태 동기화
    _ref.listen<OutboundPoListState>(outboundPoListProvider, (previous, next) {
      state = state.copyWith(outboundPoList: next);
    });

    // 🚀 [추가] 1층 출고 PO 리스트 구독/상태 동기화
    _ref.listen<Outbound1fPoListState>(outbound1fPoListProvider, (
      previous,
      next,
    ) {
      state = state.copyWith(outbound1FPoList: next);
    });

    // robotStatusProvider 구독/상태 동기화
    _ref.listen<RobotStatusState>(robotStatusProvider, (previous, next) {
      state = state.copyWith(
        ssrStatus: next.ssrStatus,
        spt1fStatus: next.spt1fStatus,
        spt3fStatus: next.spt3fStatus,
      );
    });

    // ✨ [추가] EV 상태 스트림 구독 및 동기화
    _ref.listen<AsyncValue<EvStatusEntity>>(evStatusStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((evStatus) {
        state = state.copyWith(
          isMainLiftAvailable: !evStatus.isMainError,
          isSubLiftAvailable: !evStatus.isSubError,
        );
      });
    });
  }

  // 🚀 EV 상태 변경 요청 (UI에서 호출)
  Future<void> changeEvStatus(String evName, bool toStatus) async {
    // toStatus: true(정상으로 변경), false(고장으로 변경)
    // API Spec: true(고장), false(정상) -> 반대임에 주의

    final isMain = evName == '메인 E/V';

    // 현재 상태 가져오기 (state.isAvailable이 true면 error는 false)
    final currentMainError = !state.isMainLiftAvailable;
    final currentSubError = !state.isSubLiftAvailable;

    // 변경할 에러 상태 계산 (toStatus가 정상이면 에러는 false)
    final newErrorState = !toStatus;

    // 최종 전송할 상태값 결정
    final targetMainError = isMain ? newErrorState : currentMainError;
    final targetSubError = !isMain ? newErrorState : currentSubError;

    try {
      final useCase = _ref.read(evControlUseCaseProvider);
      await useCase.execute(
        isMainError: targetMainError,
        isSubError: targetSubError,
      );
      // MQTT 응답을 기다리므로 로컬 상태 업데이트는 생략
    } catch (e) {
      // TODO: 에러 처리 (SnackBar 등)
      print('EV 상태 변경 실패: $e');
    }
  }
}

final statusPageVmProvider = StateNotifierProvider<StatusPageVM, StatusState>((
  ref,
) {
  return StatusPageVM(ref);
});
