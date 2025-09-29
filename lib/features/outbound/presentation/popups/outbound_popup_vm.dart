import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/outbound_order_entity.dart';
import '../providers/outbound_order_list_provider.dart';

class OutboundPopupState extends Equatable {
  final String doNo;
  final String savedBinNo;

  const OutboundPopupState({this.doNo = '', this.savedBinNo = ''});

  OutboundPopupState copyWith({String? doNo, String? savedBinNo}) {
    return OutboundPopupState(
      doNo: doNo ?? this.doNo,
      savedBinNo: savedBinNo ?? this.savedBinNo,
    );
  }

  @override
  List<Object?> get props => [doNo, savedBinNo];
}

class OutboundPopupVm extends StateNotifier<OutboundPopupState> {
  final Ref _ref;

  // 생성자: 초기 상태를 설정하고 다른 Provider와 통신하기 위해 ref를 받습니다.
  OutboundPopupVm(this._ref) : super(const OutboundPopupState());

  /// 스캔된 데이터로 상태를 초기화하는 메소드
  void initializeFromScan(String? scannedData) {
    if (scannedData == null || scannedData.isEmpty) return;

    // 스캔 데이터의 포맷을 분석하여 적절한 필드를 업데이트합니다. (임시 로직)
    if (scannedData.startsWith('DO-')) {
      state = state.copyWith(doNo: scannedData);
    } else {
      state = state.copyWith(savedBinNo: scannedData);
    }
  }

  // doNo 입력 필드의 값이 변경될 때 호출될 메소드
  void updateDoNo(String value) {
    state = state.copyWith(doNo: value);
  }

  // savedBinNo 입력 필드의 값이 변경될 때 호출될 메소드
  void updateSavedBinNo(String value) {
    state = state.copyWith(savedBinNo: value);
  }

  // '저장' 버튼을 눌렀을 때 호출될 메소드
  void saveOrder() {
    // 현재 팝업의 상태(doNo, savedBinNo)를 기반으로 OutboundOrderEntity를 생성
    final newOrder = OutboundOrderEntity(
      doNo: state.doNo.isNotEmpty ? state.doNo : null,
      savedBinNo: state.savedBinNo.isNotEmpty ? state.savedBinNo : null,
      startTime: DateTime.now(),
      userId: 'tester', // 실제로는 로그인 정보에서 가져와야 함
    );

    // ref를 사용해 OutboundOrderListProvider에 새 오더를 추가하도록 요청
    _ref.read(outboundOrderListProvider.notifier).addOrder(newOrder);
  }
}

/// 3. Provider 정의
final outboundPopupVMProvider =
    StateNotifierProvider.autoDispose<OutboundPopupVm, OutboundPopupState>((
      ref,
    ) {
      return OutboundPopupVm(ref);
    });
