import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outbound_1f_po_entity.dart';
import '../../domain/repositories/outbound_1f_po_repository.dart';
import 'outbound_1f_dependency_provider.dart';

// ✨ 1층 출고 PO 리스트 상태 클래스
class Outbound1fPoListState extends Equatable {
  final List<Outbound1fPoEntity> poList;
  final bool isLoading;

  const Outbound1fPoListState({
    this.poList = const [],
    this.isLoading = false,
  });

  Outbound1fPoListState copyWith({
    List<Outbound1fPoEntity>? poList,
    bool? isLoading,
  }) {
    return Outbound1fPoListState(
      poList: poList ?? this.poList,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [poList, isLoading];
}

// ✨ 1층 출고 PO 리스트 관리 Notifier
class Outbound1fPoListNotifier extends StateNotifier<Outbound1fPoListState> {
  final Outbound1fPoRepository _repository;
  StreamSubscription? _subscription;

  Outbound1fPoListNotifier(this._repository)
      : super(const Outbound1fPoListState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(isLoading: true);
    // 🚀 Repository 스트림 구독
    _subscription = _repository.outbound1fPoStream.listen(
      (poList) {
        state = state.copyWith(poList: poList, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ✨ 1층 출고 PO 리스트 제공 Provider
final outbound1fPoListProvider =
    StateNotifierProvider<Outbound1fPoListNotifier, Outbound1fPoListState>(
        (ref) {
  final repository = ref.watch(outbound1fPoRepositoryProvider);
  return Outbound1fPoListNotifier(repository);
});
