import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_mission_entity.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_mission_usecase.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_dependency_provider.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_order_list_provider.dart';

import '../../../core/state/scanner_viewmodel.dart';
import '../../../core/utils/logger.dart';
import '../domain/entities/outbound_order_entity.dart';

class OutboundScreenState {
  /// viewmodel의 상태 정의
  final bool isLoading;
  final String errorMessage;
  final bool isMissionListLoading;
  final bool isOrderListLoading;
  final bool showOutboundPopup;
  final String? scannedDataForPopup;

  /// outbound 미션 관련 UI vm
  final Set<int> selectedMissionNos;
  final OutboundMissionEntity? selectedMission;
  final bool isMissionSelectionModeActive;
  final bool isMissionDeleting;

  /// outbound 오더 관련 UI vm
  final List<OutboundOrderEntity> outboundOrders;
  final Set<String> selectedOrderNos;
  final OutboundOrderEntity? selectedOrder;
  final bool isOrderSelectionModeActive;
  final bool isOrderDeleting;

  const OutboundScreenState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isMissionListLoading = false,
    this.showOutboundPopup = false,
    this.scannedDataForPopup,
    this.isOrderListLoading = false,
    this.selectedMissionNos = const {},
    this.selectedMission,
    this.isMissionSelectionModeActive = false,
    this.isMissionDeleting = false,
    this.outboundOrders = const [],
    this.selectedOrderNos = const {},
    this.selectedOrder,
    this.isOrderSelectionModeActive = false,
    this.isOrderDeleting = false,
  });

  OutboundScreenState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isMissionListLoading,
    bool? showOutboundPopup,
    String? scannedDataForPopup,
    bool? isOrderListLoading,
    Set<int>? selectedMissionNos,
    OutboundMissionEntity? selectedMission,
    bool? isMissionSelectionModeActive,
    bool? isMissionDeleting,
    List<OutboundOrderEntity>? outboundOrders,
    Set<String>? selectedOrderNos,
    OutboundOrderEntity? selectedOrder,
    bool? isOrderSelectionModeActive,
    bool? isOrderDeleting,
  }) {
    return OutboundScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isMissionListLoading: isMissionListLoading ?? this.isMissionListLoading,
      showOutboundPopup: showOutboundPopup ?? this.showOutboundPopup,
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,
      isOrderListLoading: isOrderListLoading ?? this.isOrderListLoading,
      selectedMissionNos: selectedMissionNos ?? this.selectedMissionNos,
      selectedMission: selectedMission ?? this.selectedMission,
      isMissionSelectionModeActive:
          isMissionSelectionModeActive ?? this.isMissionSelectionModeActive,
      isMissionDeleting: isMissionDeleting ?? this.isMissionDeleting,
      outboundOrders: outboundOrders ?? this.outboundOrders,
      selectedOrderNos: selectedOrderNos ?? this.selectedOrderNos,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isOrderSelectionModeActive:
          isOrderSelectionModeActive ?? this.isOrderSelectionModeActive,
      isOrderDeleting: isOrderDeleting ?? this.isOrderDeleting,
    );
  }
}

class OutboundScreenVm extends StateNotifier<OutboundScreenState> {
  final Ref _ref;
  final OutboundMissionUseCase _getOutboundMissionUseCase;

  OutboundScreenVm({
    required Ref ref,
    required OutboundMissionUseCase getOutboundMissionUseCase,
  }) : _ref = ref,
       _getOutboundMissionUseCase = getOutboundMissionUseCase,
       super(const OutboundScreenState()) {}

  /// ===== ↓↓↓ outboundOrder 관련 메서드 섹션 ======

  // 스캔된 데이터 처리/ 팝업 호출 메서드
  void handleScannedData(String scannedData) {
    appLogger.d("아웃바운드 ViewModel handleScannedData 호출: $scannedData");

    final isScannerModeActive = _ref.read(scannerViewModelProvider);

    if (isScannerModeActive) {
      // 스캐너 모드가 활성화된 경우: 팝업을 띄우도록 상태 변경
      state = state.copyWith(
        showOutboundPopup: true,
        scannedDataForPopup: scannedData,
      );
    } else {
      // 스캐너 모드가 비활성화된 경우: 아무것도 하지 않음 (또는 다른 정책을 여기에 정의)
      appLogger.d("스캐너 모드가 비활성화되어 스캔 입력을 무시합니다.");
    }
  }

  void enableOrderSelectionMode(String orderNo) {
    state = state.copyWith(
      isOrderSelectionModeActive: true,
      selectedOrderNos: {orderNo}, // 길게 누른 오더 첫 항목으로 추가
    );
  }

  void toggleOrderForDeletion(String orderNo) {
    final currentSelection = Set<String>.from(state.selectedOrderNos);
    if (currentSelection.contains(orderNo)) {
      currentSelection.remove(orderNo);
    } else {
      currentSelection.add(orderNo);
    }
    state = state.copyWith(selectedOrderNos: currentSelection);
  }

  void disableOrderSelectionMode() {
    state = state.copyWith(
      isOrderSelectionModeActive: false,
      selectedOrderNos: {}, // 선택된 오더 초기화
    );
  }

  Future<bool> deleteSelectedOutboundOrders() async {
    if (state.selectedOrderNos.isEmpty) {
      appLogger.w("삭제할 주문이 선택되지 않았습니다.");
      return false;
    }

    state = state.copyWith(isOrderDeleting: true);

    try {
      _ref
          .read(outboundOrderListProvider.notifier)
          .removeOrders(state.selectedOrderNos);

      appLogger.d(
        "[Outbound ViewModel] OutboundOrderListProvider에 주문 삭제를 요청했습니다.",
      );

      state = state.copyWith(
        isOrderDeleting: false,
        isOrderSelectionModeActive: false,
        selectedOrderNos: {},
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isOrderDeleting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// ===== ↑↑↑ outboundOrder 관련 메서드 섹션 ======

  void showCreationPopup() {
    state = state.copyWith(showOutboundPopup: true, scannedDataForPopup: null);
  }

  /// 팝업 닫기
  void closeCreationPopup(bool isVisible) {
    state = state.copyWith(showOutboundPopup: false, scannedDataForPopup: null);
  }

  /// ====== ↓↓↓ OutboundMission 관련 메서드 섹션 ======
  /// 스트림 구독, mission 상태를 업데이트

  /// 사용자가 미션을 터치했을 때 : 선택모드가 아닐 때 개별 mission의 정보 가져옴.
  void selectMission(OutboundMissionEntity mission) {
    state = state.copyWith(
      selectedMission: mission,
      isMissionSelectionModeActive: false,
      selectedMissionNos: {},
    );
  }

  /// 선택 모드 활성화 : 길게 눌렀을 때 미션선택모드로 변경
  void enableSelectionMode(int subMissionNo) {
    state = state.copyWith(
      isMissionSelectionModeActive: true,
      selectedMissionNos: {subMissionNo}, // 길게 누른 미션 첫 항목으로 추가
    );
  }

  /// 선택 모드 비활성화 : 선택모드에서 취소 버튼 눌렀을 때
  void disableSelectionMode() {
    state = state.copyWith(
      isMissionSelectionModeActive: false,
      selectedMissionNos: {}, // 선택된 미션 초기화
    );
  }

  /// 미션 선택/해제 : 선택모드에서 미션을 눌렀을 때
  void toggleMissionForDeletion(int subMissionNo) {
    final currentSelection = Set<int>.from(state.selectedMissionNos);
    if (currentSelection.contains(subMissionNo)) {
      currentSelection.remove(subMissionNo);
    } else {
      currentSelection.add(subMissionNo);
    }
    state = state.copyWith(selectedMissionNos: currentSelection);
  }

  /// 선택된 미션 삭제 api 요청
  Future<bool> deleteSelectedOutboundMissions() async {
    if (state.selectedMissionNos.isEmpty) {
      appLogger.w("삭제할 미션이 선택되지 않았습니다.");
      return false;
    }

    state = state.copyWith(isMissionDeleting: true);

    try {
      var selectedMissions = state.selectedMissionNos.toList();
      appLogger.d("[Outbound ViewModel] 선택된 미션 삭제 요청: $selectedMissions");
      await _getOutboundMissionUseCase.deleteSelectedOutboundMissions(
        selectedMissionNos: selectedMissions,
      );

      // 삭제 성공 시 상태 업데이트
      state = state.copyWith(
        isMissionDeleting: false,
        isMissionSelectionModeActive: false,
        selectedMissionNos: {},
        selectedMission: null,
      );

      return true;
    } catch (e) {
      // 에러 발생 시 상태 업데이트
      state = state.copyWith(
        isMissionDeleting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// ====== ↑↑↑ OutboundMission 관련 메서드 섹션 ======

  /// viewmodel 소멸 시 스트림 구독 취소, 리소스 해제
  @override
  void dispose() {
    _getOutboundMissionUseCase.dispose();
    super.dispose();
  }
}

final outboundScreenViewModelProvider =
    StateNotifierProvider<OutboundScreenVm, OutboundScreenState>((ref) {
      /// 1.  UseCase Provider 를 watch하여 UseCase 구현체를 주입받음
      final getOutboundMissionUseCase = ref.watch(
        outboundMissionUseCaseProvider,
      );
      return OutboundScreenVm(
        ref: ref,
        getOutboundMissionUseCase: getOutboundMissionUseCase,
      );
    });
