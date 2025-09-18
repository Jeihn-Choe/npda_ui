import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup_viewmodel.dart';
import 'package:npda_ui_flutter/features/login/presentation/providers/login_providers.dart';

import '../../domain/usecases/add_inbound_item_usecase.dart';
import '../../domain/usecases/add_inbound_item_usecase_impl.dart';
import '../notifiers/inbound_registration_list_notifier.dart';
import '../state/inbound_registration_list_state.dart';

// UseCase Provider
final addInboundItemUseCaseProvider = Provider<AddInboundItemUseCase>((ref) {
  return AddInboundItemUseCaseImpl();
});

// StateNotifier Provider
final inboundRegistrationListProvider =
    StateNotifierProvider<
      InboundRegistrationListNotifier,
      InboundRegistrationListState
    >((ref) {
      final addInboundItemUseCase = ref.watch(addInboundItemUseCaseProvider);
      return InboundRegistrationListNotifier(addInboundItemUseCase);
    });

// InboundRegistrationPopupViewModel Provider
final inboundRegistrationPopupViewModelProvider =
    ChangeNotifierProvider.autoDispose((ref) {
      final loginState = ref.watch(loginViewModelProvider);
      final popupViewModel = InboundRegistrationPopupViewModel();
      popupViewModel.initialize(loginState);
      return popupViewModel;
    });
