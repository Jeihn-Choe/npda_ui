import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/status/domain/pending_order_entity.dart';

class StatusState {
  final bool isMainLiftAvailable;
  final bool isSubLiftAvailable;
  final double ssrStatus;
  final List<PendingOrderEntity> pendingOrders;

  StatusState({
    required this.isMainLiftAvailable,
    required this.isSubLiftAvailable,
    required this.ssrStatus,
    required this.pendingOrders,
  });

  StatusState copyWith({
    bool? isMainLiftAvailable,
    bool? isSubLiftAvailable,
    double? ssrStatus,
    List<PendingOrderEntity>? pendingOrders,
  }) {
    return StatusState(
      isMainLiftAvailable: isMainLiftAvailable ?? this.isMainLiftAvailable,
      isSubLiftAvailable: isSubLiftAvailable ?? this.isSubLiftAvailable,
      ssrStatus: ssrStatus ?? this.ssrStatus,
      pendingOrders: pendingOrders ?? this.pendingOrders,
    );
  }
}

class StatusPageVM extends StateNotifier<StatusState> {
  StatusPageVM()
    : super(
        StatusState(
          isMainLiftAvailable: true,
          isSubLiftAvailable: true,
          ssrStatus: 100.0,
          pendingOrders: [
            PendingOrderEntity(huId: '801088817', missionType: 1),
            PendingOrderEntity(huId: '801088817', missionType: 1),
          ],
        ),
      );
}

final statusPageVMProvider = StateNotifierProvider<StatusPageVM, StatusState>((
  ref,
) {
  return StatusPageVM();
});
