import 'package:flutter_riverpod/flutter_riverpod.dart';
// ✨ 추가: Repository 관련 임포트
import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup_viewmodel.dart';

import '../../data/repositories/inbound_sm_repository_impl.dart';
import '../../domain/repositories/inbound_sm_repository.dart';
import '../../domain/usecases/inbound_order_usecase.dart';
import '../inbound_page_vm.dart';

/// 입고 요청을 위한 프로바이더 모음

// RequestInboundWorkUseCase - 구현체 연결 Provider
final inboundOrderUseCaseProvider = Provider<InboundOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return InboundOrderUseCase(repository);
});

// InboundRegistrationPopupViewModel Provider
final inboundRegistrationPopupViewModelProvider =
    ChangeNotifierProvider.autoDispose((ref) {
      final popupViewModel = InboundRegistrationPopupViewModel(ref);
      popupViewModel.initialize();
      return popupViewModel;
    });

// [GET CURRENT INBOUND MISSIONS]
///  입고 미션 현황 관련 프로바이더 모음

// ✨ 추가: InboundMissionRepository 제공자
final inboundMissionRepositoryProvider = Provider<InboundSmRepository>((ref) {
  // Core의 MqttStreamRepository Provider를 watch
  final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
  return InboundSmRepositoryImpl(mqttStreamRepository);
});

/// ViewModel - 구현체 연결 Provider
final inboundPageVMProvider =
    StateNotifierProvider<InboundPageVm, InboundPageState>((ref) {
      return InboundPageVm(ref);
    });
