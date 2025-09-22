import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/get_current_inbound_missions_usecase.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/request_inbound_work_usecase.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup_viewmodel.dart';
import 'package:npda_ui_flutter/features/login/presentation/providers/login_providers.dart';

import '../../../../core/network/http/api_provider.dart';
import '../../data/repositories/current_inbound_mission_repository_impl.dart';
import '../../data/repositories/request_inbound_work_repository_impl.dart';
import '../../domain/repositories/current_inbound_mission_repository.dart';
import '../../domain/repositories/request_inbound_work_repository.dart';
import '../../domain/usecases/add_inbound_item_usecase.dart';
import '../../domain/usecases/add_inbound_item_usecase_impl.dart';
import '../../domain/usecases/request_inbound_work_usecase_impl.dart';
import '../inbound_viewmodel.dart';
import '../notifiers/inbound_registration_list_notifier.dart';
import '../state/inbound_registration_list_state.dart';

/// 입고 요청을 위한 프로바이더 모음

// AddInboundItemUseCase - 구현체 연결 Provider
final addInboundItemUseCaseProvider = Provider<AddInboundItemUseCase>((ref) {
  return AddInboundItemUseCaseImpl();
});

// InboundRepository - 구현체 연결 Provider
final requestInboundWorkRepositoryProvider =
    Provider<RequestInboundWorkRepository>((ref) {
      /// 레파지토리에서 통신을 담당하므로
      /// apiService 구독
      final apiService = ref.watch(apiServiceProvider);

      /// apiService 주입해서 레파지토리 구현체 반환 => 이타이밍에 메모리에 구현체가 올라감
      return RequestInboundWorkRepositoryImpl(apiService);

      /// Mock 서버 사용 시
      // return RequestInboundWorkRepositoryMock();
    });

// RequestInboundWorkUseCase - 구현체 연결 Provider
final requestInboundWorkUseCaseProvider = Provider<RequestInboundWorkUseCase>((
  ref,
) {
  /// useCase에서 repository를 사용하기 때문에 주입해줘야함.
  /// 주입은 구독으로 일어남. 즉 repository를 구현하기 위해서는 provider를 구독해야함.
  final repository = ref.watch(requestInboundWorkRepositoryProvider);
  return RequestInboundWorkUseCaseImpl(repository);
});

// StateNotifier Provider
final inboundRegistrationListProvider =
    StateNotifierProvider<
      InboundRegistrationListNotifier,
      InboundRegistrationListState
    >((ref) {
      // 스캔 후 아이템 추가 유스케이스 => AddInboundItemUseCase
      final addInboundItemUseCase = ref.watch(addInboundItemUseCaseProvider);

      // 작업 요청 유스케이스 => RequestInboundWorkUseCase
      final requestInboundWorkUseCase = ref.watch(
        requestInboundWorkUseCaseProvider,
      );

      // Inbound List의 상태를 바꿀 수 있는 유스케이스는 2개
      // 두 유스케이스를 주입해서 Notifier 구현체 반환
      // Inbound List의 상태를 바꾸고 싶다면 Notifier를 통해서만 가능하므로,
      // 바꿔말하면 Notifier가 상태를 바꿀 수 있도록 유스케이스를 주입해줘야함.
      return InboundRegistrationListNotifier(
        addInboundItemUseCase,
        requestInboundWorkUseCase,
      );
    });

// InboundRegistrationPopupViewModel Provider
final inboundRegistrationPopupViewModelProvider =
    ChangeNotifierProvider.autoDispose((ref) {
      final loginState = ref.watch(loginViewModelProvider);
      final popupViewModel = InboundRegistrationPopupViewModel();
      popupViewModel.initialize(loginState);
      return popupViewModel;
    });

// [GET CURRENT INBOUND MISSIONS]
///  입고 미션 현황 관련 프로바이더 모음

/// Repository - 구현체 연결 Provider
final currentInboundMissionRepositoryProvider =
    Provider<CurrentInboundMissionRepository>((ref) {
      final repository = CurrentInboundMissionRepositoryImpl();

      // provider가 dispose될 때 리소스 해제
      ref.onDispose(() => repository.dispose());

      return repository;
    });

/// UseCase - 구현체 연결 Provider
final getCurrentInboundMissionsUseCaseProvider =
    Provider<GetCurrentInboundMissionsUseCase>((ref) {
      final repository = ref.watch(currentInboundMissionRepositoryProvider);
      return GetCurrentInboundMissionsUseCase(repository);
    });

/// ViewModel - 구현체 연결 Provider
final inboundViewModelProvider =
    StateNotifierProvider<InboundViewModel, CurrentInboundMissionState>((ref) {
      final useCase = ref.watch(getCurrentInboundMissionsUseCaseProvider);
      return InboundViewModel(getCurrentInboundMissionsUseCase: useCase);
    });
