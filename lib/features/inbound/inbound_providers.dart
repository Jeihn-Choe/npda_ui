import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecase/add_inbound_item_usecase.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecase/add_inbound_item_usecase_impl.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup_viewmodel.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_viewmodel.dart';

import '../../core/utils/logger.dart';
import 'domain/entities/inbound_registration_item.dart';

/// Usecase provider
/// AddInboundItemUseCase 구현체 주입
final addInboundItemProvider = Provider<AddInboundItemUseCase>((ref) {
  return AddInboundItemUseCaseImpl();
});

/// 상태 관리자 provider
/// InboundRegistrationPopupViewModel 상태관리자
final inboundRegistrationPopupViewModelProvider =
    ChangeNotifierProvider.autoDispose((ref) {
      final loginState = ref.watch(loginViewModelProvider);
      final popupViewModel = InboundRegistrationPopupViewModel();
      popupViewModel.initialize(loginState);
      return popupViewModel;
    });

/// InboundRegistrationListNotifier 상태 관리자
final inboundRegistrationListProvider =
    StateNotifierProvider<
      InboundRegistrationListNotifier,
      List<InboundRegistrationItem>
    >((ref) {
      final addInboundItemUseCase = ref.watch(addInboundItemProvider);
      return InboundRegistrationListNotifier(
        addInboundItemUseCase: addInboundItemUseCase,
      );
    });

/// 상태 관리자 클래스 정의
/// StateNotifier를 사용하여 Inbound 등록 항목 목록 관리
class InboundRegistrationListNotifier
    extends StateNotifier<List<InboundRegistrationItem>> {
  final AddInboundItemUseCase addInboundItemUseCase;

  InboundRegistrationListNotifier({required this.addInboundItemUseCase})
    : super([]);

  /// UI의 호출을 받아 Usecase를 호출하고 상태를 업데이트
  Future<void> addInboundItem({
    required String? pltNo,
    required DateTime? workStartTime,
    required String? userId,
    required String? selectedRackLevel,
  }) async {
    try {
      // Usecase 호출하여 새로운 항목 추가
      final newState = await addInboundItemUseCase(
        currentList: state,
        pltNo: pltNo,
        workStartTime: workStartTime,
        userId: userId,
        selectedRackLevel: selectedRackLevel,
      );
      // 상태 업데이트
      state = newState;
    } catch (e) {
      // 에러 처리 (필요시 로깅 등)
      logger('Error adding inbound item: $e');
      // 에러를 다시 던져서 UI에서 처리할 수 있도록 함
      rethrow;
    }
  }
}
