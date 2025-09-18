import '../../domain/entities/inbound_registration_item.dart';

class InboundRegistrationListState {
  // 입고요청되는 전체 item 리스트
  final List<InboundRegistrationItem> items;

  // ui에서 선택된 pltNo 들의 집합
  final Set<String> selectedPltNos;
  final bool isLoading;

  const InboundRegistrationListState({
    this.items = const [],
    this.selectedPltNos = const {},
    this.isLoading = false,
  });

  InboundRegistrationListState copyWith({
    List<InboundRegistrationItem>? items,
    Set<String>? selectedPltNos,
    bool? isLoading,
  }) {
    return InboundRegistrationListState(
      items: items ?? this.items,
      selectedPltNos: selectedPltNos ?? this.selectedPltNos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
