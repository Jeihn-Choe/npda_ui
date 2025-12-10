import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_po_entity.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_po_list_provider.dart';
import 'package:npda_ui_flutter/features/status/domain/pending_order_entity.dart';

import '../../../core/utils/logger.dart';

class StatusState {
  final bool isMainLiftAvailable;
  final bool isSubLiftAvailable;
  final double ssrStatus;
  final List<PendingOrderEntity> pendingOrders;
  final List<InboundPoEntity> inboundPoList;

  StatusState({
    required this.isMainLiftAvailable,
    required this.isSubLiftAvailable,
    required this.ssrStatus,
    required this.pendingOrders,
    this.inboundPoList = const [],
  });

  StatusState copyWith({
    bool? isMainLiftAvailable,
    bool? isSubLiftAvailable,
    double? ssrStatus,
    List<PendingOrderEntity>? pendingOrders,
    List<InboundPoEntity>? inboundPoList,
  }) {
    return StatusState(
      isMainLiftAvailable: isMainLiftAvailable ?? this.isMainLiftAvailable,
      isSubLiftAvailable: isSubLiftAvailable ?? this.isSubLiftAvailable,
      ssrStatus: ssrStatus ?? this.ssrStatus,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      inboundPoList: inboundPoList ?? this.inboundPoList,
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
          ssrStatus: 100.0,
          pendingOrders: [
            PendingOrderEntity(huId: '801088817', missionType: 1),
            PendingOrderEntity(huId: '801088817', missionType: 1),
          ],
          inboundPoList: [],
        ),
      ) {
    _init();
  }

  void _init() {
    // ✨ inboundPoListProvider 구독하여 상태 동기화
    _ref.listen<InboundPoListState>(inboundPoListProvider, (previous, next) {
      if (previous?.poList != next.poList) {
        state = state.copyWith(inboundPoList: next.poList);
      }
    });
    
    // 초기 로드 (이미 데이터가 있을 경우를 대비)
    final currentPoState = _ref.read(inboundPoListProvider);
    if (currentPoState.poList.isNotEmpty) {
       state = state.copyWith(inboundPoList: currentPoState.poList);
    }
  }
}

final statusPageVMProvider = StateNotifierProvider<StatusPageVM, StatusState>((
  ref,
) {
  return StatusPageVM(ref);
});
