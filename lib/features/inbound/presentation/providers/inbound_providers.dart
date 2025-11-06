import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/core/providers/usecase_providers.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/inbound_mission_usecase.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup_viewmodel.dart';

import '../../domain/usecases/inbound_order_usecase.dart';
import '../inbound_page_vm.dart';

/// 입고 요청을 위한 프로바이더 모음

// RequestInboundWorkUseCase - 구현체 연결 Provider
final inboundOrderUseCaseProvider = Provider<InboundOrderUseCase>((ref) {
  // ✨ 변경: 중앙 orderRepositoryProvider를 watch
  final repository = ref.watch(orderRepositoryProvider);
  return InboundOrderUseCase(repository);
});

// InboundRegistrationPopupViewModel Provider
final inboundRegistrationPopupViewModelProvider =
    ChangeNotifierProvider.autoDispose((ref) {
      final popupViewModel = InboundRegistrationPopupViewModel(ref);
      popupViewModel.initialize(); // initialize()는 이제 파라미터 없음
      return popupViewModel;
    });

// [GET CURRENT INBOUND MISSIONS]
///  입고 미션 현황 관련 프로바이더 모음

/// UseCase
final inboundMissionUseCaseProvider = Provider<InboundMissionUseCase>((ref) {
  final mqttMessageRouterUseCase = ref.watch(mqttMessageRouterUseCaseProvider);
  final missionRepository = ref.watch(missionRepositoryProvider);

  final useCase = InboundMissionUseCase(
    mqttMessageRouterUseCase,
    missionRepository,
  );

  useCase.startListening();

  ref.onDispose(() {
    useCase.dispose();
  });

  return useCase;
});

/// ViewModel - 구현체 연결 Provider
final inboundPageVMProvider =
    StateNotifierProvider<InboundPageVm, InboundPageState>((ref) {
      // ✨ 변경: 생성자에서 UseCase 의존성 제거
      return InboundPageVm(ref);
    });
